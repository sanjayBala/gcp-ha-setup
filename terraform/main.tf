
resource "google_compute_instance" "lb" {
  name         = "lb-1"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  metadata = {
    ssh-keys = "sanbalaj:${file("~/.ssh/id_rsa.pub")}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  metadata_startup_script = "sudo apt-get update; sudo apt install -y haproxy"
  network_interface {
    network = "default"
    access_config {
    }
  }
  tags = ["http-server"]
}

resource "google_compute_instance" "backend" {
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  count        = var.backend_server_count
  name         = "${var.backend_server_prefix}-${count.index}"
  metadata = {
    ssh-keys = "sanbalaj:${file("~/.ssh/id_rsa.pub")}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -y nginx"
  network_interface {
    network = "default"
    access_config {
    }
  }
  tags = ["http-server"]
}

resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "local_file" "prep_ansible" {
  depends_on = [google_compute_instance.backend, google_compute_instance.lb]
  content    = <<-DOC
  [controller]
  control ansible_connection=local

  [loadbalancer]
  ${google_compute_instance.lb.network_interface.0.access_config.0.nat_ip} ansible_user=sanbalaj

  [backend_servers]
  ${google_compute_instance.backend.0.network_interface.0.access_config.0.nat_ip} ansible_user=sanbalaj
  ${google_compute_instance.backend.1.network_interface.0.access_config.0.nat_ip} ansible_user=sanbalaj
  
  [defaults]
  host_key_checking = False
  DOC
  filename   = "./dev.txt"
}

resource "null_resource" "playbook_nginx" {
  depends_on = [local_file.prep_ansible]
  provisioner "local-exec" {
    command = <<EOT
    cd ../ansible
    ansible-playbook playbook-nginx.yml -b    
    EOT
  }
}

resource "null_resource" "playbook_haproxy" {
  depends_on = [local_file.prep_ansible]
  provisioner "local-exec" {
    command = <<EOT
    cd ../ansible
    ansible-playbook playbook-haproxy.yml -b --extra-vars 'backend_ip_a=${google_compute_instance.backend.0.network_interface.0.access_config.0.nat_ip} backend_ip_b=${google_compute_instance.backend.1.network_interface.0.access_config.0.nat_ip} make_sticky=${var.make_sticky}'
    EOT
  }
}

resource "google_dns_managed_zone" "zone_creation" {
  depends_on = [null_resource.playbook_haproxy, null_resource.playbook_nginx]
  name     = "test-sanjay-alation"
  dns_name = "test-zone-sanjay.com."
}

resource "google_dns_record_set" "lb_dns_entry" {
  depends_on = [google_dns_managed_zone.zone_creation]
  managed_zone = google_dns_managed_zone.zone_creation.name

  name    = "www.${google_dns_managed_zone.zone_creation.dns_name}"
  type    = "A"
  rrdatas = [google_compute_instance.lb.network_interface.0.access_config.0.nat_ip]
  ttl     = 300
}