FROM golang:latest as golang

FROM ubuntu

ARG TARGETARCH

# Install default packages
RUN apt update && apt upgrade -y && apt install -y curl wget zip git jq build-essential  postgresql-client

# Install Go
COPY --from=golang /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

# Install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  apt install -y nodejs

# Clean packages
RUN rm -rf /var/lib/apt/lists/*

# Install Vault
RUN wget -O vault.zip https://releases.hashicorp.com/vault/1.13.1/vault_1.13.1_linux_${TARGETARCH}.zip && \
  unzip vault.zip && \
  mv vault /usr/local/bin

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && \
  mv ./kubectl /usr/local/bin && \
  chmod +x /usr/local/bin/kubectl

RUN wget -O terraform.zip https://releases.hashicorp.com/vault/1.13.1/vault_1.13.1_linux_${TARGETARCH}.zip && \
  unzip vault.zip && \
  mv vault /usr/local/bin

# Install code server
RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | sh

RUN code-server serve-local --accept-server-license-terms --install-extension shipyard.shipyard
RUN code-server serve-local --accept-server-license-terms --install-extension golang.go
RUN code-server serve-local --accept-server-license-terms --install-extension hashicorp.hcl
RUN code-server serve-local --accept-server-license-terms --install-extension hashicorp.terraform
RUN code-server serve-local --accept-server-license-terms --install-extension pkief.material-icon-theme
RUN code-server serve-local --accept-server-license-terms --install-extension whizkydee.material-palenight-theme

RUN go install github.com/ramya-rao-a/go-outline@v0.0.0-20210608161538-9736a4bde949 && \
  go install golang.org/x/tools/gopls@latest && \
  go install github.com/cweill/gotests/gotests@v1.6.0 && \
  go install github.com/fatih/gomodifytags@v1.16.0 && \
  go install github.com/josharian/impl@v1.1.0 && \ 
  go install github.com/haya14busa/goplay/cmd/goplay@v1.0.0 && \
  go install github.com/go-delve/delve/cmd/dlv@latest && \
  go install honnef.co/go/tools/cmd/staticcheck@latest && \
  go install golang.org/x/tools/gopls@latest && \
  go install github.com/ramya-rao-a/go-outline@v0.0.0-20210608161538-9736a4bde949

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]