network "dc1" {
  subnet = "10.5.0.0/16"
}

k8s_cluster "dc1" {
  driver = "k3s"

  nodes = 1

  network {
    name = "network.dc1"
  }
}

output "KUBECONFIG" {
  value = k8s_config("dc1")
}