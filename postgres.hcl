container "postgres" {
  depends_on = ["k8s_cluster.dc1", "template.vscode"]

  network {
    name       = "network.dc1"
    ip_address = "10.5.0.205"
  }

  image {
    name = "hashicorpdemoapp/product-api-db:v0.0.11"
  }

  port {
    local  = 5432
    remote = 5432
    host   = 5433
  }

  env {
    key   = "POSTGRES_DB"
    value = "wizard"
  }

  env {
    key   = "POSTGRES_USER"
    value = "postgres"
  }

  env {
    key   = "POSTGRES_PASSWORD"
    value = "password"
  }
}