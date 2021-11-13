resource "google_compute_firewall" "db" {
  project = "nginx-328009"
  name    = "db"
  network = google_compute_network.webserver.id
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1433", "22"]
  }
  source_ranges = ["10.0.0.0/16"]
  target_tags   = ["db"]
}

resource "google_compute_firewall" "bastion" {
  project = "nginx-328009"
  name    = "bastion"
  network = google_compute_network.webserver.id
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
    ports    = ["16839"]
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "web" {
  project = "nginx-328009"
  name    = "web"
  network = google_compute_network.webserver.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}