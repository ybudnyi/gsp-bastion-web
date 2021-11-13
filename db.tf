resource "google_compute_instance" "database" {
  name         = "db"
  machine_type = "e2-micro"
  zone         = "us-central1-b"
  tags         = ["db"]
  boot_disk {
    initialize_params {
      image = "db-sql"
    }
  }
  metadata = {
    ssh-keys = "yurii:${file("~/.ssh/id_rsa.pub")}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.private.id
  }
}
output "db_url" {
  value = google_compute_instance.database.network_interface.0.network_ip
}