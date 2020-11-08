title "Inspect Infrastructure"

gcp_project_id = attribute("gcp_project_id")
zone = attribute("zone")
shape = attribute("shape")
dns_zone = attribute("dns_zone")
dns_entry = attribute("dns_entry")
http_firewall = attribute("http_firewall")

control 'check-instance-count' do
  impact 1.0
  title "Checking the instance count."
  describe google_compute_instances(project: gcp_project_id,  zone: zone) do
    its('instance_ids.count') { should be >= 3 }
  end
end

control 'check-instance-state' do
  impact 1.0
  title "Check Status of VMs"
  google_compute_instances(project: gcp_project_id, zone: zone).instance_names.each do |instance_name|
    describe google_compute_instance(project: gcp_project_id, zone: zone, name: instance_name) do
      its('status') { should eq 'RUNNING' }
      its('machine_type') { should match shape }
    end
  end
end

control 'check-instance-network' do
  impact 1.0
  title "Check Network of VMs"
  google_compute_instances(project: gcp_project_id, zone: zone).instance_names.each do |instance_name|
    describe google_compute_instance(project: gcp_project_id, zone: zone, name: instance_name) do
      its('tags.items') { should include 'http-server' }
    end
  end
end

control 'check-dns-record' do
  impact 1.0
  title "Check DNS Record"
  describe google_dns_resource_record_set(project: gcp_project_id, name: dns_entry, type: 'A', managed_zone: dns_zone) do
    it { should exist }
    its('type') { should eq 'A' }
    its('ttl') { should eq 300 }
  end
end

control 'check-http-traffic' do
  impact 1.0
  title "Check if http is allowed"
  describe google_compute_firewall(project: gcp_project_id, name: http_firewall) do
    its('allowed_http?')  { should be true }
  end
end