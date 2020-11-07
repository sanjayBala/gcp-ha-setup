output "LB_IP" {
  value = google_compute_instance.lb.network_interface.0.access_config.0.nat_ip
}

output "backend-IPs" {
  value = [google_compute_instance.backend.*.network_interface.0.access_config.0.nat_ip]
}