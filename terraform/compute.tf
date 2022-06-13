resource "google_compute_instance" "controllers" {
  count = var.num_controllers

  name = "k8s-controller-${count.index}"
  machine_type = "e2-standard-2"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      size = 200
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.default.id
    network_ip = "10.240.0.1${count.index}"
    subnetwork = google_compute_subnetwork.default.id
  }

  service_account {
    scopes = [
        "compute-rw", 
        "storage-ro", 
        "service-management", 
        "service-control", 
        "logging-write", 
        "monitoring" 
        ]
  }

  tags = [
      "k8s-the-hard-way", 
      "controller"
      ]
}

resource "google_compute_instance" "workers" {
  count = var.num_controllers

  name = "k8s-worker-${count.index}"
  machine_type = "e2-standard-2"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      size = 200
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.default.id
    network_ip = "10.240.0.2${count.index}"
    subnetwork = google_compute_subnetwork.default.id
  }

  service_account {
    scopes = [
        "compute-rw", 
        "storage-ro", 
        "service-management", 
        "service-control", 
        "logging-write", 
        "monitoring" 
        ]
  }

  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
  }

  tags = [
      "k8s-the-hard-way", 
      "worker"
      ]
}