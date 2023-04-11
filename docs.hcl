docs "docs" {
  path  = "./docs"
  port  = 3000
  open_in_browser = false

  image {
    name = "shipyardrun/docs:v0.6.2"
  }

  index_title = "Vault"

  network {
    name = "network.dc1"
  }
}