path "kv1/payments" {
  capabilities = ["read"]
}

path "kv2/data/payments" {
  capabilities = ["read"]
}

path "database/creds/db-app" {
  capabilities = ["read"]
}

path "pki/issue/payments" {
  capabilities = ["update"]
}

path "transit/encrypt/payments" {
  capabilities = ["update"]
}