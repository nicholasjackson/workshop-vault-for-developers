variable "nginx_docs_domain_suffix" {
  default = ".docs.shipyard.run"
}

variable "nginx_code_domain_suffix" {
  default = ".container.shipyard.run"
}

template "nginx_config" {

  source = <<-EOF
    server {
      listen       80  default_server;
      server_name  _;
      return       444;
    }

    server {
      listen 80;
      listen [::]:80;
      server_name ~^([0-9]+)${var.nginx_docs_domain_suffix};

      location / {
        proxy_pass http://10.5.0.201;
        proxy_http_version 1.1;
      }
    }

    server {
      listen 80;
      listen [::]:80;
      server_name ~^([0-9]+)${var.nginx_code_domain_suffix};

      location / {
        proxy_pass http://10.5.0.200:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
      }
    }
  EOF

  destination = "${data("nginx")}/nginx.conf"
}

container "nginx" {
  depends_on = ["template.nginx_config"]

  network {
    name = "network.dc1"
  }

  image {
    name = "nginx:latest"
  }

  port {
    local  = 80
    remote = 80
    host   = 80
  }

  volume {
    source = "${data("nginx")}/nginx.conf"
    destination = "/etc/nginx/conf.d/default.conf"
  }
}