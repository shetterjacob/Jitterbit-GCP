provider "google" {
  project          = var.project_id
  region           = var.region
}

data "google_compute_zones" "placeholder" {
  region           = var.region
  project          = var.project_id
}

resource "google_compute_network" "placeholder" {
    name                    = "${var.name}-vpc" //give the vpc name
    provider                = google
    auto_create_subnetworks = false
    routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "placeholder" {
    name          = "${var.name}-subnet"   // give the subnet name
    ip_cidr_range = var.ip_cidr_range       //give the cidr_range
    region        = var.region     // give the region
    network       = google_compute_network.placeholder.self_link  //specify vpc
}

resource "google_compute_firewall" "jitterbit-access" {
  project       = var.project_id
  name          = "jitterbit-access"
  network       = google_compute_network.placeholder.self_link
  description   = "Creates firewall rule targeting tagged instances"
  source_ranges = ["71.120.182.247/32"]
  target_tags   = ["jitterbit-access"]

  allow {
    protocol  = "tcp"
    ports     = ["22"]
  }
}

resource "google_compute_disk" "dev-disk" {
  name  = "dev-disk"
  type  = "pd-balanced"
  zone  = "us-central1-a"
  size  = 100
  labels = {
    environment = "dev"
  }
}

resource "google_compute_disk" "prod-disk" {
  name  = "prod-disk"
  type  = "pd-balanced"
  zone  = "us-central1-a"
  size  = 100
  labels = {
    environment = "prod"
  }
}


resource "google_compute_instance" "dev" {
  machine_type        = "n2-custom-8-16384"
  name                = "${var.name}-dev"
  zone                = var.zone
  tags                = ["jitterbit-access"]
  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  attached_disk {
    source      = google_compute_disk.dev-disk.self_link
    mode        = "READ_WRITE"
  }

  boot_disk {
    auto_delete = true
    device_name = "boot_disk"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240607"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    network         = google_compute_network.placeholder.self_link
    subnetwork      = google_compute_subnetwork.placeholder.self_link
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "1079502158005-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
}

resource "google_compute_instance" "prod" {
  machine_type        = "n2-custom-8-16384"
  name                = "${var.name}-prod"
  zone                = var.zone
  tags                = ["jitterbit-access"]
  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  attached_disk {
    source      = google_compute_disk.prod-disk.self_link
    mode        = "READ_WRITE"
  }

  boot_disk {
    auto_delete = true
    device_name = "boot_disk"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240607"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    network         = google_compute_network.placeholder.self_link
    subnetwork      = google_compute_subnetwork.placeholder.self_link
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "1079502158005-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
}
