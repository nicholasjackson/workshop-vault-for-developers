---
title: Leveraging Transit Secrets from Applications
sidebar_label: Leveraging Transit Secrets from Applications
---

To use the transit secrets from an application you POST a payload similar
to the following example to the path:

`[vault address]/v1/transit/encrypt/[key name]`

```json
{
  "plaintext": "base64data"
}
```

If you were to do this with the local Vault server then the path would be:

`http://localhost:8200/v1/transit/encrypt/payments`

To see an example of this code take a look at the file `client.go` in the
folder `app/vault`.

```go title="app/vault/client.go"
url := fmt.Sprintf("%s/v1/transit/encrypt/%s", c.addr, c.key)

// base64 encode
base64cc := base64.StdEncoding.EncodeToString([]byte(cc))

data, _ := json.Marshal(EncryptRequest{Plaintext: base64cc})
r, _ := http.NewRequest(http.MethodPost, url, bytes.NewReader(data))

// if we have a vault token add it, if not assume that there is a local
// agent that is transparently authenticating requests
if c.token != "" {
	r.Header.Add("X-Vault-Token", c.token)
}

resp, err := http.DefaultClient.Do(r)
if err != nil {
	return "", err
}
defer resp.Body.Close()
```

From a Go perspective this is fairly trivial task, the problem that you face
is managing the authentication and the Vault token to be able to make an
authenticated request to Vault.

Thankfully the Vault Agent has a capability to expose a local proxy to the 
remote Vault server. This local proxy automatically adds authentication to
each request using the token it already has.

## Configuring Vault Agent to act as a local proxy

To configure Vault Agent to work as a local proxy you need to configure
three additional stanzas:

* cache
* api_proxy
* listener

Let's look at these one by one

### `cache` stanza

The cache stanza enables secret caching for the local application, it can
save load on the Vault Server by enabling client side caching of secrets.

The basic in-memory configuration of the cache looks like the following:

```javascript
cache {
}
```

### `api_proxy` stanza 

The next block is the `api_proxy` stanza, this configures Vault Agent to act
as an API proxy. Setting the `use_auto_auth_token` to `force` ensures that
the Agents Vault token is always used even if the client includes a Vault token
with the request.

```javascript
api_proxy {
  use_auto_auth_token = "force"
}
```

### `listener` stanza

Finally you need to configure a `listener`, the listener exposes a local
socket for the proxy. Listeners can either by `tcp` or `unix` sockets.

In our listener configuration you are setting the address to be `localhost`
and are disabling TLS. If `tls_disable` is not set to `true`, then you
need to provide a TLS certificate and key to secure the local proxy. 

```javascript
listener "tcp" {
  address     = "127.0.0.1:8100"
  tls_disable = true
}
```

### complete example

The complete example looks like the following, add this to your `config.hcl`
after the `auto_auth` section.

```javascript
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
```

You can then stop the agent `ctrl-c`, and then restart it.

<VSCodeTerminal target="Agent">
  <Command>vault agent --config=./vault_agent/config.hcl</Command>
</VSCodeTerminal>

```shell
vault agent --config=./vault_agent/config.hcl
```

## Encrypting data with the application

Before you can use the application you need to ensure that the `payments` policy
that Vault Agent is using has the required permission to encrypt data.

### Adding the encryption permissions to the `payments` policy

Add the following to your `payments.hcl`

```javascript
path "transit/encrypt/payments" {
  capabilities = ["update"]
}
```

Then update the policy in Vault

<VSCodeTerminal target="Vault">
  <Command>
    vault policy write payments ./policy/payments.hcl
  </Command>
</VSCodeTerminal>

```shell
vault policy write payments ./policy/payments.hcl
```

The payments application is now able to use Vault Agent to encrypt data.

### Executing the request

The example application has the API endpoint `/pay` this accepts a payload
that looks like the following.

```json
{
  "card_number": "1234-3434-3434-3434"
}
```

Why not try this by running the following command in your terminal.

<VSCodeTerminal target="Vault">
  <Command>
    curl https://localhost:9091/pay \
      -k -s \
      -d '&#123;"card_number": "1234-3434-3434-3434"}' \
      | jq 
  </Command>
</VSCodeTerminal>

```shell
curl https://localhost:9091/pay \
  -k -s \
  -d '&#123;"card_number": "1234-3434-3434-3434"}' \
  | jq 
```

That almost completes the workshop, before you go, how about one last challenge.

## Challenge 

Why not try to decrypt the data that is returned by the API.

<details>
<summary>Answer</summary>

Did you manage to come up with a solution that looks like the following?

<VSCodeTerminal target="Vault">
  <Command>
    curl https://localhost:9091/pay \
      -k -s \
      -d '&#123;"card_number": "1234-3434-3434-3434"}' \
      | jq -r '.ciphertext' \
      > ciphertext.txt && \
    vault write --format=json \
      transit/decrypt/payments \
      ciphertext=$(cat ciphertext.txt) \
      | jq -r '.data.plaintext' \
      | base64 -d
  </Command>
</VSCodeTerminal>

```shell
curl https://localhost:9091/pay \
  -k -s \
  -d '&#123;"card_number": "1234-3434-3434-3434"}' \
  | jq -r '.ciphertext' \
  > ciphertext.txt

vault write --format=json \
  transit/decrypt/payments \
  ciphertext=$(cat ciphertext.txt) \
  | jq -r '.data.plaintext' \
  | base64 -d
```
</details>

## Summary

Congratulations, you made it to the end of the workshop, you have now learned
some of the most common features of Vault and how they are used within applications.

We hope you have enjoyed the workshop and have found it useful, this only
covers a small portion of the things that you can do with Vault. Please feel
free to browse the documentation and experiment with some other features.