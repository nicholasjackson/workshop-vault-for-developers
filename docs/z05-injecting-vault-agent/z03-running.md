---
title: Running Vault Agent
sidebar_label: Running Vault Agent
---

Let's see how to run Vault Agent and how it transforms the given configuration
and templates into your required output. 

Vault Agent is built into the same Vault binary that is used for the Vault CLI 
and to run a Vault Server. 

To run it you use the following command:

```shell
vault agent --config=[path to your config]
```

Let's now run Vault Agent, run the following in the terminal.

<VSCodeTerminal target="Agent">
  <Command>vault agent --config=./vault_agent/config.hcl</Command>
</VSCodeTerminal>

```shell
vault agent --config=./vault_agent/config.hcl
```

Vault Agent runs as a daemon, you should see output that looks like the following.

```shell
==> Vault Agent started! Log data will stream in below:

==> Vault Agent configuration:

           Api Address 1: http://127.0.0.1:8100
           Api Address 2: http://bufconn
                     Cgo: disabled
               Log Level: 
                 Version: Vault v1.13.1, built 2023-03-23T12:51:35Z
             Version Sha: 4472e4a3fbcc984b7e3dc48f5a8283f3efe6f282
#...
2023-04-12T09:18:21.183+0100 [INFO]  agent.apiproxy: received request: method=PUT path=/v1/sys/leases/renew
2023-04-12T09:18:21.183+0100 [INFO]  agent.apiproxy: forwarding request to Vault: method=PUT path=/v1/sys/leases/renew
2023-04-12T09:18:21.186+0100 [INFO] (runner) rendered "(dynamic)" => "config.json"
```

## Checking the output

Let's now test the output that has been generated correctly.

If you check the contents of the file `./tls/cert.pem`

<VSCodeTerminal target="Vault">
  <Command>cat ./tls/cert.pem</Command>
</VSCodeTerminal>

```shell
cat ./tls/cert.pem
```

You should see output that looks like the following:

```shell
-----BEGIN CERTIFICATE-----
MIIDgzCCAmugAwIBAgIUSe6Lf5FX+7lufu3U3Gbf2+7Y4MQwDQYJKoZIhvcNAQEL
BQAwEjEQMA4GA1UEAxMHZGVtby5nczAeFw0yMzA0MTIwODE3NTFaFw0yMzA0MTMw
ODE4MjFaMAAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCis2NJSsli
r2N4IZcLviyrAym/xWilFfcKeliC2lJDtzi6jEUefU3ZXfT/qfpxVvYtl1dziRQu
j0fOAnVolkVKRNdzUq4DzuE2u7A7kXMPJk0vfs4aDIaQ9kY8EsbOle1NLK49O+zf
f8aEEqlckio0VC6cLh/jDfgg12VTtV+YaOjbJxeNHPOYSXKXdQ6Vigjo/k6+Ckiw
wOJeRnPHPZ5Fj2hY+i7QKmxDqFPd5Adcc4Le8FN2UYrnVnvWZl6Y0Lokvw2sVnyG
Dj5FXYZkgUnNIgqRKUVB6hzKjRdvM6mCHDTOsUi716UhK+IUKqHXGdoQhz6kDPyR
jAtSTymJDQl1AgMBAAGjgeIwgd8wDgYDVR0PAQH/BAQDAgOoMB0GA1UdJQQWMBQG
CCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUPTRFriec48tSDMToC4TnYZxN
NuMwHwYDVR0jBBgwFoAUFw/88B2QZKsNqqoIn1SFzIAreaEwOwYIKwYBBQUHAQEE
LzAtMCsGCCsGAQUFBzAChh9odHRwOi8vbG9jYWxob3N0OjgyMDAvdjEvcGtpL2Nh
MDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly9sb2NhbGhvc3Q6ODIwMC92MS9wa2kv
Y3JsMA0GCSqGSIb3DQEBCwUAA4IBAQBAu187TF6ZfYcXB2Ui0mlgsW7rHS3VJHod
YCfbxRjtEftGiRmkFih0uaObKFKbXKdgVhVALIu4mhG+///JeZOCcyZklbU8cOdq
JUhB5jRi5EddN7uS97amo+0MS+i5hg8+Piaps2RI5FyBaUcrGiHXcsikHX7ZI5PB
znX7U6F6+1AgSwbawt5d+54XrEzxo5elUC7yNnIeSJfseEfpvBG5iQ07LY00WEp2
7h7sMvC+wcT5ivHoScyFN0zJGY5vHOduRwpw9vmrZGZiZl3u48WQ+UdFVfLEiNWE
2njiSoRfAWdVwaxnnXv/4SiyyJtbmogIucqzvqD08aOliIEe634B
-----END CERTIFICATE-----
```

Also the file `./tls/key.pem` should have been created

<VSCodeTerminal target="Vault">
  <Command>cat ./tls/key.pem</Command>
</VSCodeTerminal>

```shell
cat ./tls/key.pem
```

```shell
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAorNjSUrJYq9jeCGXC74sqwMpv8VopRX3CnpYgtpSQ7c4uoxF
Hn1N2V30/6n6cVb2LZdXc4kULo9HzgJ1aJZFSkTXc1KuA87hNruwO5FzDyZNL37O
GgyGkPZGPBLGzpXtTSyuPTvs33/GhBKpXJIqNFQunC4f4w34INdlU7VfmGjo2ycX
jRzzmElyl3UOlYoI6P5OvgpIsMDiXkZzxz2eRY9oWPou0CpsQ6hT3eQHXHOC3vBT
dlGK51Z71mZemNC6JL8NrFZ8hg4+RV2GZIFJzSIKkSlFQeocyo0XbzOpghw0zrFI
u9elISviFCqh1xnaEIc+pAz8kYwLUk8piQ0JdQIDAQABAoIBAQCSCuoFYP8R+RMV
Qzl9DfC0dLtl60I6ZVQB8L5Afs43AGEIel6Utq9JfSAs2Zv3XrLNS7rw90vJW019
6xEOl0yNFOw8FSwkOPBJnAHeBno8UAoapv1DvpiPyLBUvhn8V/HRQ1kHmCHQoLZF
2SZy9LSzkhjgkjqHKgPfHtlSYUz01U++Ka8xoML3baSHnjXOWOylZv7+sHMem9pZ
MH6ZCCY7Ek5HV9ED0YuziwyIyXww2D2iblcy3j2NxdQg5SbZhnCTSabWY3xxNeap
bBXzhtbR0AcNvZQNTSeRvP+AgSsVbEj/F4JtnV4cNoPmspmwcUVqiUVOUcOEwVsv
WY2105KBAoGBAMF4zcid5kffBuSBx2cF5RaBVz3lbkqo6A4kyosbLG4F2jy7Y3nm
d28+L+Ijj7U3pDpJbp37M4sBIg1z+Zcm1u/roux7NSc0IIcpygFsukObM4pxDEnd
vPfkXTreTmSWxFw1GJYpLxUdgGdz/AtZxK2eSVJpNuJyIEe4RsIh24RhAoGBANdI
r000ltiZF/XYtQq9QHO925tl9w/j0+YOzGdsTnbXhTDdhQ3xQ7C1dMDuJ3nr8HIy
Yf2cM5qrPugA+9tXwVaz8PJfD7sw+cZFqtsulHE/255tecrjJo5gj1Mho+35J2sG
mv41wiFXtludQEaoGy21h6exEG76vri7eQbaih2VAoGAOdQnBlEUFOV4BPM5q/Sa
Hhj4/7pFNjG4cwnSNLQhmp1LNx33xOb7Shf3bgudF9iS0Q1D8Bq2tFTZXdYNg32L
f1kacL7/C0HMezoldDmQj0ajqDzUJHwP0LTEnST3n59k//6q469ZsGEKEWIcszPY
0uBeIDDsw9DDD0zocXx3ReECgYAw9jXwUCqSflcFsdCS7bHP4PkmIY2MDputseXp
C6fYvXFsSKUvI5TqhopUKpXN08wunKjOngzae2HmL/sXyqCNEIWXCemxABV+c2/F
Q5W9H/HZ2Toe24R0Ux+ln3wB7m15mNn9QMqy/JjbwyrQJwFvZt7AU7PSGbLwnqqK
1X8d9QKBgDIrixRbIBWNQIFTgx3ail39Vb2Lt3LeOJkobK0bD27YxdRR0M+6Zf+O
28QmcFmSrTVKRDN9jkQw9vKojygi/ZoAEd2RTAEepRODWjaowClfQkUvZA3nLaPi
4KA31Nkdt0Y8FE1DPUF22y7GR5Ld7JtqKy3N17eA2MpkAF3XEAdG
-----END RSA PRIVATE KEY-----
```

Let's see how you can add additional templates to your configuration.

## Adding Additional Templates

In addition to certificates, the example payments application, needs
a JSON configuration file that looks like the following:

```json
{
  "bind_address": ":9091",
  "vault_addr": "http://localhost:8200",
  "db_connection": "postgresql://username:password@localhost:5432/wizard",
  "api_key": "{{ .Data.data.api_key }}"
}
```

To generate this file, Vault Agent configuration can have multiple `template` 
stanzas, meaning it is possible that your single Vault Agent config can
output both the certificates and the JSON config.

### Challenge

Why not have a go at adding an additional `template` stanza to generate
this config and write it to a file `config.json`. The secrets that you need
to use to achieve this are the same secrets you used previously.

* database/creds/db-app
* kv2/data/payments

Hint: this configuration should look very familiar as it is the same that 
you created for Kubernetes.


<details>
  <summary>Answer</summary>

You should have added a `template` block to your `config.hcl` that looks 
like the following.

```javascript
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
```

</details>

With the new config added, let's restart Vault Agent to render the new output.

## Restarting Vault Agent

To restart Vault Agent, navigate to your terminal and press `ctrl-c` to stop
Vault Agent.


You can then re-start it with the same commands as you used before.

<VSCodeTerminal target="Agent">
  <Command>vault agent --config=./vault_agent/config.hcl</Command>
</VSCodeTerminal>

```shell
vault agent --config=./vault_agent/config.hcl
```

Once Vault Agent is up and running, you can check the `config.json`
file that it has generated.

<VSCodeTerminal target="Agent">
  <Command>cat config.json</Command>
</VSCodeTerminal>

```shell
cat config.json
```

You should see something that looks like the following:

```json
{
  "bind_address": ":9091",
  "vault_addr": "http://localhost:8200",
  "db_connection": "postgresql://v-approle-db-app-6trHV6O6tp5Z2dRqUwod-1681290387:mCorOdGBVi2E35NH-IFk@postgres:5432/wizard",
  "api_key": "abc123"
}
```

Now that you understand how the configuration works, let's run the example application
and learn how your application can respond to changes in a secret.