variable "vscode_password" {
  default = "testing123"
}

container "vscode" {
  network {
    name = "network.dc1"
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
    value = "/root/.shipyard/config/dc1/kubeconfig-docker.yaml"
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
    source      = "."
    destination = "/working"
  }

  volume {
    source      = k8s_config_docker("dc1")
    destination = "/root/.shipyard/config/dc1/kubeconfig-docker.yaml"
  }
}