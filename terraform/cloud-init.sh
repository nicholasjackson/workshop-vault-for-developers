#!/usr/bin/env bash

# Set the hostname to something recognizable
hostnamectl set-hostname "shipyard-$${HOSTNAME/#"ip"}"

# Add Docker repository
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"

# Add Shipyard repository
echo "deb [trusted=yes] https://apt.fury.io/shipyard-run/ /" | tee -a /etc/apt/sources.list.d/fury.list

# Add HashiCorp repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install packages
apt update && apt install -y jq vim net-tools \
  docker-ce \
  shipyard

# Run Shipyard
shipyard run github.com/nicholasjackson/workshop-vault-for-developers \
  --var "vscode_password=${passcode}" \
  --var "nginx_docs_domain_suffix=${docs_suffix}" \
  --var "nginx_code_domain_suffix=${code_suffix}"