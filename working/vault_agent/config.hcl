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

cache {
}

api_proxy {
  use_auto_auth_token = "force"
  enforce_consistency = "always"
}

listener "tcp" {
  address     = "127.0.0.1:8100"
  tls_disable = true
}

template {
  contents = <<-EOF
    {{ with secret "pki/issue/payments" "ttl=1m" "common_name=payments.demo.gs"}}
      {{ .Data.certificate | writeToFile "./tls/cert.pem" "" "" "0644" }}
      {{ .Data.private_key | writeToFile "./tls/key.pem" "" "" "0644" }}
      {{ .Data.certificate }}
    {{ end }}
  EOF

  destination = "cert.pem"

  exec {
    // adding | true to the command will stop Vault agent from retrying
    // should the sighup fail
    command = "kill -HUP $(cat ./working/app/app.pid) | true"
  }
}

template {
  contents = <<-EOF
  {
    "bind_address": ":9091",
    "vault_addr": "http://localhost:8100",
    "vault_encryption_key": "payments",
    {{ with secret "database/creds/db-app" -}}
    "db_connection": "postgresql://{{ .Data.username }}:{{ .Data.password }}@localhost:5432/wizard?sslmode=disable",
    {{- end }}
    {{- with secret "kv2/data/payments" }}
    "api_key": "{{ .Data.data.api_key }}"
    {{- end }}
  }
  EOF

  destination = "config.json"
}