variable "vault_k8s_cluster" {
  default = "dc1"
}

module "vault" {
  source = "github.com/shipyard-run/blueprints?ref=4be3f83118bfcd57349bf623ae41b59b83d663f0/modules//kubernetes-vault"
}