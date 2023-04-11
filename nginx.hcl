template "nginx_config" {

  source = <<-EOF
    server {
      listen 80;
      listen [::]:80;
      server_name ~^([0-9]+)-workshop-docs.demo.gs;

      location / {
        proxy_pass http://docs.docs.shipyard.run;
        proxy_http_version 1.1;
      }
    }

    server {
      listen 80;
      listen [::]:80;
      server_name ~^([0-9]+)-workshop-vscode.demo.gs;

      location / {
        proxy_pass http://vscode.container.shipyard.run:8000;
        proxy_http_version 1.1;
      }
    }
    
    server {
      listen 80;
      listen [::]:80;
      server_name ~^([0-9]+).docs.shipyard.run;

      location / {
        proxy_pass http://docs.docs.shipyard.run;
        proxy_http_version 1.1;
      }
    }

    server {
      listen 80;
      listen [::]:80;
      server_name ~^([0-9]+).container.shipyard.run;

      location / {
        proxy_pass http://vscode.container.shipyard.run:8000;
        proxy_http_version 1.1;
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