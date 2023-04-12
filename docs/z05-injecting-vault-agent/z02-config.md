---
title: Configuring Vault Agent
sidebar_label: Configuring Vault Agent
---

Create a new file in the folder `./vault_agent` called `agent-config.hcl`.
You will then work through the agent config 

## Configuring the Vault Stanza

Vault Agent needs to know the location of the Vault server, in our example
system this is accessible at `http://localhost:8200`. Let's add the `vault`
stanza block to the file you just created.

```javascript
vault {
  address = "http://localhost:8200"
  retry {
    num_retries = 5
  }
}
```

Next you need to configure authentication for the agent.

## Configuring the Auto Auth Stanza

The `auto_auth` stanza is where the authentication configuration is defined.
The below example uses the `.role-id` and `.secret-id` files that you created
in a previous step to authenticate with Vault. 

This stanza follows a consistent approach, the `type` defines the authentication
type to use, in this case `approle`. The `config` block contains authentication
specific configuration.

Add this configuration to your `agent-config.hcl` file after the `vault` 
stanza.

```javascript
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
```

You can learn more about the different `auto_auth` methods in the following
documentation. Not all Vault Auth methods are supported by `auto_auth` but 
the most common ones are.

https://developer.hashicorp.com/vault/docs/agent/autoauth


Once authentication is configured you can configure one or more `template`
stanzas to generate your application specific configuration.

## Generating secrets using templates

Let's create a template that can generate an x590 certificate and key that 
can be used to secure the transport of the example application.

While the language for this template is the same as the one you configured
when building the Kuberentes example, this template is a little different as
it does not directly generate a file. Instead it uses the `writeToFile` function
in consul-template that enables a secret to be directly written to a file.

```javascript
{{ .Data.Cert | writeToFile "./tls/cert.pem" "[user id]" "[group]" "[permissions]"}}
```

```javascript
{{ .Data.Cert | writeToFile "./tls/cert.pem" "nicj" "applications" "0644"}}
```

https://github.com/hashicorp/consul-template/blob/main/docs/templating-language.md#writetofile

The reason that we are not simple generating the file with the `template` is that 
to generate the certificate and key you would require two templates.

Templates can not share secrets and since a call to `pki/issue/payments` would
generate a new certificate and key with each call, should you create two templates
then the key and certificate would not match.

Add the following template block to your `config.hcl` file and you can then 
run Vault Agent to see all of this in action.

Note: we have to provided a `destination` for the template as this is a required
field. Vault Agent will create this file but the contents will be empty as the
certificates are written to the files `./tls/cert.pem` and `./tls/key.pem`.

Add this section to your `config.hcl` after the `auto_auth` stanza

```javascript
template {
  contents = <<-EOF
    {{ with pkiCert "pki/issue/payments" "ttl=24h"}}
      {{ .Data.Cert | writeToFile "./tls/cert.pem" "" "" "0644"}}
      {{ .Data.Key | writeToFile "./tls/key.pem" "" "" "0644"}}
    {{ end }}
  EOF

  destination = "certs.txt"
}
```

Now the configuration file is complete, let's see how this can be used.