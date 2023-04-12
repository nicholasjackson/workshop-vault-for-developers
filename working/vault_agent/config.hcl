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
    command = "kill -HUP $(cat ./working/app/app.pid)"
  }
}

template {
  contents = <<-EOF
  {
    "bind_address": ":9091",
    "vault_addr": "http://localhost:8200",
    {{ with secret "database/creds/db-app" -}}
    "db_connection": "postgresql://{{ .Data.username }}:{{ .Data.password }}@postgres:5432/wizard",
    {{- end }}
    {{- with secret "kv2/data/payments" }}
    "api_key": "{{ .Data.data.api_key }}"
    {{- end }}
  }
  EOF

  destination = "config.json"
}