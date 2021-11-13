resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-micro"
  zone         = "us-central1-b"
  tags         = ["bastion"]
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210720"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.public.id
    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  metadata = {
    ssh-keys = "yurii:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "yurii"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.access_config.0.nat_ip
    agent       = false
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install curl -y gnupg2 wget unzip",
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv E162F504A20CDF15827F718D4B7C549A058F8B6B",
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A",
      "echo 'deb http://repo.pritunl.com/stable/apt focal main' | sudo tee /etc/apt/sources.list.d/pritunl.list",
      "sudo apt update",
      "sudo apt install -y pritunl",
      "sudo systemctl stop pritunl",
      "sudo systemctl start pritunl",
      "sudo systemctl enable pritunl",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list",
      "sudo apt update",
      "sudo apt-get install -y mongodb-server"
    ]
  }
}