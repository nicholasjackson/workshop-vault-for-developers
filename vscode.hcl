container "vscode" {
  network {
    name = "network.dc1"
  }

  image {
    name = "shipyardrun/docker-devs-vscode:v0.0.1"
  }

  port {
    local  = 8000
    remote = 8000
    host   = 443
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

  volume {
    source = "."
    destination = "/working"
  }
}