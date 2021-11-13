resource "google_compute_network" "webserver" {
  project                 = "nginx-328009"
  name                    = "webserver"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}
resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.webserver.id
}

resource "google_compute_subnetwork" "private" {
  name          = "private"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.webserver.id
}

resource "google_compute_address" "ip_address" {
  name = "my-address"
}

resource "google_compute_router" "web" {
  name = "web-router"
  region = "us-central1"
  project = "nginx-328009" 
  network = google_compute_network.webserver.self_link
}

resource "google_compute_router_nat" "natweb" {
  name = "nat-web"
  project = "nginx-328009"
  router = google_compute_router.web.name
  region = "us-central1"
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  depends_on = [
    google_compute_subnetwork.private
  ]
}