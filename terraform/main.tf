terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.61.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
}

provider "google" {
  # Configuration options
  region = "europe-west4"
  project = "hc-8fffbd82081b4fb2b203c4a6255"
}

resource "google_compute_firewall" "rules" {
  name        = "shipyard-ingress"
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["shipyard"]
}

resource "random_id" "rnd" {
  byte_length = 4
}

resource "google_compute_instance" "default" {
  count = 1

  name         = "vault-workshop-${count.index}"
  machine_type = "e2-medium"
  zone         = "europe-west4-a"

  tags = ["workshop", "shipyard"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
    
  }

  metadata_startup_script = templatefile("${path.module}/cloud-init.sh",{})

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "cloudflare_record" "dns-vscode" {
  zone_id = "8542f7e55a8c0cd9c215478cf157e613"
  name    = "0-workshop-vscode"
  value   = google_compute_instance.default.0.network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "dns-docs" {
  zone_id = "8542f7e55a8c0cd9c215478cf157e613"
  name    = "0-workshop-docs"
  value   = google_compute_instance.default.0.network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "dns-vscode-noproxy" {
  zone_id = "8542f7e55a8c0cd9c215478cf157e613"
  name    = "1-workshop-vscode"
  value   = google_compute_instance.default.0.network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "dns-docs-noproxy" {
  zone_id = "8542f7e55a8c0cd9c215478cf157e613"
  name    = "1-workshop-docs"
  value   = google_compute_instance.default.0.network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = false
}

output "public_ips" {
  value = [google_compute_instance.default.*.network_interface.0.access_config.0.nat_ip]
}