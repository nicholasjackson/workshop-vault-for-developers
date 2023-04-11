vault {
  address = "http://localhost:8200"
  retry {
    num_retries = 5
  }
}

auto_auth {
  method {
    type = "approle"

    config = {
      role_id_file_path                   = ".role-id"
      secret_id_file_path                 = ".secret-id"
      remove_secret_id_file_after_reading = false
    }
  }
}

cache {}

listener "tcp" {
    address = "127.0.0.1:8100"
    tls_disable = true
}

template {
  contents = <<-EOF
  {
    "bind_address": ":9091",
    "vault_addr": "http://localhost:8200",
    "vault_token_file": ".vault-token",
    {{ with pkiCert "pki/issue/a_demo_gs" "ttl=1m"}}
    "tls_cert": "{{ base64Encode .Data.Cert }}",
    "tls_key": "{{ base64Encode .Data.Key }}"
    {{ end }}
  }
  EOF

  destination = "config.json"
}