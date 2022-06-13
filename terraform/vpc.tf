resource "google_compute_network" "default" {
  name = "k8s-the-hard-way-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name = "k8s-the-hard-way-subnet"
  ip_cidr_range = var.subnet_cidr
  region = var.region
  network = google_compute_network.default.id 
}

resource "google_compute_firewall" "default" {
  name = "k8s-the-hard-way-fw"
  network = google_compute_network.default.id

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}

resource "google_compute_firewall" "external" {
  name = "k8s-the-hard-way-fw-external"
  network = google_compute_network.default.id
  
  allow {
    protocol = "tcp"
    ports = [
        "22", 
        "6443"
        ]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "default" {
  name = "k8s-the-hard-way"
  region = var.region
}
