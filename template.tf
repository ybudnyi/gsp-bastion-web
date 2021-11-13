resource "google_compute_instance_template" "web_server" {
  name                 = "webserver-template"
  description          = "This template creates instance with docker runtime"
  instance_description = "Web Server"
  can_ip_forward       = false
  machine_type         = "g1-small"
  tags                 = ["web"]
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = "docker-1636789752"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.webserver.id
    subnetwork = google_compute_subnetwork.private.id
  }

  lifecycle {
    create_before_destroy = true
  }
  metadata = {
    startup_script = <<SCRIPT
      export DB_HOST="${google_compute_instance.database.network_interface.0.network_ip}"
      sudo touch /var/file.txt
      sudo chmod 777 /var/file.txt
      sudo echo $DB_HOST > /var/file.txt
      sudo docker login --username ${var.username} --password ${var.password}
      sudo docker run -d -p 80:80 yeasy/simple-web:latest
      
      SCRIPT
  }
}