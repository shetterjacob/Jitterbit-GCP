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
    network       = google_compute_network.jitterbit.id  //specify vpc
}

resource "google_compute_network_firewall_policy_rule" "jitterbit-rdp" {
  action                  = "allow"
  description             = "This is a rule to allow RDP from known IP addresses"
  direction               = "INGRESS"
  disabled                = false
  enable_logging          = true
  firewall_policy         = google_compute_network_firewall_policy.jitterbit-rdp.self_link
  priority                = 1000
  rule_name               = "jitterbit-rdp"

  match {
    src_ip_ranges = ["71.120.182.247/32"]
    src_region_codes = ["US"]
    src_threat_intelligences = ["iplist-known-malicious-ips"]
    }

    layer4_configs {
      ip_protocol = "tcp"
      ports       = "3389"
    }
        target_secure_tags {
          name    = "jitterbit-access"
        }

    src_address_groups = [google_network_security_address_group.basic_global_networksecurity_address_group.id]
}


resource "google_compute_instance" "production" {
  name            = "${var.name}-prod"
  machine_type    = var.vm_type
  zone            = var.zone
  tags            = ("jitterbit-prod","jitterbit-access")

  boot_disk {
    initialize_params {
      image         = "Windows Server 2022 Datacenter"
    }
  }

  compute_disk {
    name    = "${var.name}-dev"
    type    = "pd-balanced"
    size    = 100
  }
  network_interface {
    network         = google_compute_network.placeholder.self_link
    subnetwork      = google_compute_subnetwork.placeholder.self_link
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "development" {
  name            = "${var.name}-dev"
  machine_type    = var.vm_type
  zone            = var.zone
  tags            = ("jitterbit-dev"), ("jitterbit-access")

  boot_disk {
    initialize_params {
      image = "Windows Server 2022 Datacenter"
    }
  }
  compute_disk {
    name    = "${var.name}-dev"
    type    = "pd-balanced"
    size    = 100
  }

  network_interface {
    network         = google_compute_network.placeholder.self_link
    subnetwork      = google_compute_subnetwork.placeholder.self_link
    access_config {
      // Ephemeral IP
    }
  }

}
