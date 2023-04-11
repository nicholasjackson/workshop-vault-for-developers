variable "vscode_password" {
  default = "testing123"
}

variable "docs_location" {
  default = "http://localhost:3000/"
}

template "vscode" {
  source = <<-EOF
  {
    "tabs": [
      {"uri": "${var.docs_location}", "title": "Docs"}
    ],
    "terminals": [
      {"name": "Vault", "viewColumn": 1}
    ]
  }
  EOF

  destination = "${data("vscode")}/shipyard.json"
}

container "vscode" {
  depends_on = ["k8s_cluster.dc1", "template.vscode"]

  network {
    name       = "network.dc1"
    ip_address = "10.5.0.200"
  }

  image {
    name = "shipyardrun/docker-devs-vscode:v0.0.2"
  }

  port {
    local  = 8000
    remote = 8000
    host   = 8000
  }

  env {
    key   = "VAULT_TOKEN"
    value = "root"
  }

  env {
    key   = "KUBECONFIG"
    value = k8s_config_docker("dc1")
  }

  env {
    key   = "VAULT_ADDR"
    value = "http://${shipyard_ip()}:8200"
  }

  env {
    key   = "AUTH_KEY"
    value = var.vscode_password
  }

  volume {
    source      = "./working"
    destination = "/working"
  }

  volume {
    source      = k8s_config_docker("dc1")
    destination = k8s_config_docker("dc1")
  }

  volume {
    destination = "/working/.vscode"
    source      = data("vscode")
  }
}