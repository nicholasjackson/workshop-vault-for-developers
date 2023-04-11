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

variable "instances" {
  default = 5
}

variable "domain" {
  default = "demo.gs"
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
  count = var.instances

  byte_length = 8
}

resource "google_compute_instance" "default" {
  count = var.instances

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

  metadata_startup_script = templatefile(
    "${path.module}/cloud-init.sh",{
      passcode=random_id.rnd[count.index].hex
      code_suffix="-workshop-vscode.${var.domain}"
      docs_suffix="-workshop-docs.${var.domain}"
    })

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "cloudflare_record" "dns-vscode" {
  count = var.instances

  zone_id = "8542f7e55a8c0cd9c215478cf157e613"
  name    = "${count.index}-workshop-vscode"
  value   = google_compute_instance.default[count.index].network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "dns-docs" {
  count = var.instances

  zone_id = "8542f7e55a8c0cd9c215478cf157e613"
  name    = "${count.index}-workshop-docs"
  value   = google_compute_instance.default[count.index].network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = true
}

output "public_ips" {
  value = [google_compute_instance.default.*.network_interface.0.access_config.0.nat_ip]
}

output "codes" {
  value = [random_id.rnd.*.hex]
}
