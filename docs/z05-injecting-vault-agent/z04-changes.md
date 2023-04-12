---
title: Responding To Changes
sidebar_label: Responding To Changes
---

Let's first run our application and test that our config is valid.


<VSCodeTerminal target="App">
  <Command>
    cd ./app && \
    CONFIG_FILE=../config.json \
    TLS_CERT=../tls/cert.pem \
    TLS_KEY=../tls/key.pem \
    go run main.go  
  </Command>
</VSCodeTerminal>

```shell
cd ./app && \
CONFIG_FILE=../config.json \
TLS_CERT=../tls/cert.pem \
TLS_KEY=../tls/key.pem \
go run main.go  
```

You will see some log output that shows the server is running

```shell
2023-04-12T10:19:57.068+0100 [INFO]  Starting Server: bind=:9091
```

You can call the health end point for the application

<VSCodeTerminal target="Vault">
  <Command>
  curl https://localhost:9091/health
  </Command>
</VSCodeTerminal>

```shell
curl https://localhost:9091/health
```

Since the server is running with TLS and the certificate has been self signed
by Vault you will see the following error message.

```shell
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

You could work round this problem by using the insecure `-k` flag for curl;
however, the best option is to fetch the CA from Vault and to use this to
correctly validate the request.

## Fetching the CA from Vault

The CA can be retrieved from vault by reading from the correct endpoint 
for the pki secrets engine.


### Challenge

Why don't you have a go at retrieving the ca and storing it in a file 
called `ca.pem`.

The documentation for the CA endpoints can be found at the following location.

https://developer.hashicorp.com/vault/api-docs/secret/pki#accessing-authority-information

<details>
  <summary>Answer</summary>

Get it right?

You should have run the following command:

<VSCodeTerminal target="Vault">
  <Command>
vault read --format=json pki/cert/ca \
  | jq -r .data.certificate \
  > "ca.pem"
  </Command>
</VSCodeTerminal>

```shell
vault read --format=json pki/cert/ca \
  | jq -r .data.certificate \
  > "ca.pem"
```
</details>

With the CA stored in the file `ca.pem` let's make that request again, but
this time passing the `--cacert [file]` flag that allows curl to validate
the servers certificate against the given CA.

You will also need to pass the `--connect-to` flag as the certificate has a common
name of `payments.demo.gs` but the server is running at localhost.

<VSCodeTerminal target="Vault">
  <Command>
  curl -v \
    --cacert ca.pem \
    --connect-to payments.demo.gs:9091:localhost:9091 \
    https://payments.demo.gs:9091/health
  </Command>
</VSCodeTerminal>

```shell
curl -v \
  --cacert ca.pem \
  --connect-to payments.demo.gs:9091:localhost:9091 \
  https://payments.demo.gs:9091/health
```

This time you should see the correct output

```shell
< HTTP/2 200 
< content-length: 0
< date: Wed, 12 Apr 2023 09:47:16 GMT
< 
* Connection #0 to host (nil) left intact
```

## Reloading the Configuration

The application writes its process id to the file
`./app/app.pid`. It also responds to the `HUP` signal.

When the application receives this signal it will 
reload its configuration and certificates.

You can simulate this by running the following command

<VSCodeTerminal target="Vault">
  <Command>
  kill -HUP $(cat ./working/app/app.pid)
  </Command>
</VSCodeTerminal>

```
kill -HUP $(cat ./working/app/app.pid)
```

If you look at the output for the application you will see that the log
files show the application has reloaded the configuration.

```shell
2023-04-12T11:02:06.695+0100 [INFO]  Stopping Server
2023-04-12T11:02:06.696+0100 [INFO]  Starting Server: bind=:9091
```

When a template changes Vault Agent can automatically run command such as
this HUP command.

```javascript
exec {
  command = "kill -HUP $(cat ./working/app/app.pid)"
}
```

https://developer.hashicorp.com/vault/docs/agent/template#exec

Let's update the template to add this capability, to see it in action
let's also reduce the TTL for the certificate to 1 minute.

Note: The `exec` command will only execute when the `destination` file changes
in the previous example you were not outputting anything to this file so
`exec` will never get called. By writing the cert to the cert.pem file, 
in addition to the `./tls` folder exec will get correctly called and you will
see the application reload the certificates.

```
{{ .Data.certificate }}
```

Replace the template that generate the certificates in your Vault Agent
configuration with the following contents:

```javascript
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
    command = "kill -HUP $(cat ./working/app/app.pid) | true"
  }
}
```

You can then stop the agent (`ctrl-c`) and restart it.

<VSCodeTerminal target="Agent">
  <Command>vault agent --config=./vault_agent/config.hcl</Command>
</VSCodeTerminal>

```shell
vault agent --config=./vault_agent/config.hcl
```

After approximately one minute, you will see the application reload
the configuration as it receives the `HUP` signal from Vault Agent.

```
2023-04-12T12:07:18.592+0100 [INFO]  Received SIGHUP, reloading
2023-04-12T12:07:18.592+0100 [INFO]  Config file updated: config="&{:9091 http://localhost:8200 postgresql://v-approle-db-app-7a6HMwXUJxE4QZfwoYcN-1681297369:od4aKZcYZ94BLRaxu-3H@postgres:5432/wizard }"
2023-04-12T12:07:18.592+0100 [INFO]  Stopping Server
2023-04-12T12:07:18.592+0100 [INFO]  Starting Server: bind=:9091
```

Now you have learned how to react to changes in secrets, let's progress to
the final part of this workshop and learn how to interact with Vault `Transit Secrets`
backend.

