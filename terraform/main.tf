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
    ports     = ["8000", "3000", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["shipyard"]
}

resource "google_dns_managed_zone" "example-zone" {
  name        = "workshop"
  dns_name    = "workshop-${random_id.rnd.hex}.com."
  description = "Example DNS zone"
}

resource "random_id" "rnd" {
  byte_length = 4
}

resource "google_compute_firewall" "rules_ipv6" {
  name        = "shipyard-ingress-ipv6"
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["8000", "3000", "22"]
  }

  source_ranges = ["::/0"]
  target_tags = ["shipyard"]
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
    
    ipv6_access_config {
      // Ephemeral public IP
      network_tier = "STANDARD"
    }
  }

  metadata_startup_script = templatefile("${path.module}/cloud-init.sh",{})

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "cloudflare_record" "default" {
  count = 1

  zone_id = "8542f7e55a8c0cd9c215478cf157e613"
  name    = "${count.index}-vault-workshop"
  value   = google_compute_instance.default[count.index].network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = true
}

output "public_ips" {
  value = [google_compute_instance.default.*.network_interface.0.access_config.0.nat_ip]
}