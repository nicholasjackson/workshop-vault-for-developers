---
title: Configuring Authentication
sidebar_label: Configuring Authentication
---

To obtain secrets from Vault, Vault Agent needs to authenticate to Vault.
In the Kubernetes example you configured Vault Agent to use Kubernetes
Service Account Tokens for authentication. In this section we also need 
authenticate but since we will not be using Kubernetes we need another method.

There are a large number of different authentication mechanisms you can use,
many of which require external services for validation (e.g. Okta, Kubernetes,
AWS,, GitHub). When this capability is not available `AppRole` is commonly
used.

AppRole allows machines or applications to authenticate with Vault using a
pre-configured role and secret. This is a similar concept to a username or
password. However, AppRole secrets can have constraints that enable them to
have a particular validity and limited number of uses.

Let's configure AppRole so that you can use this for the Vault Agent example.

## Configuring AppRole Authentication

The first step is to enable the approle authentication engine.

<VSCodeTerminal target="Vault">
  <Command>vault auth enable approle</Command>
</VSCodeTerminal>

```shell
vault auth enable approle
```

Next you need to configure a role that enables the generation of a role-id
and role-secret. This role is going to have a secret ttl of `2 hours`, and
the resulting token that is returned when authentication is successful is 
limited to `2 hours`. The returned token will also have access to the 
secrets defined in the policy `payments`.

A role like this is not suitable for a long lived process, once the token
has expired after 2 hours then Vault Agent would need to re-authenticate
in order to maintain access to the secrets. Since the AppRole secret-id
also has a TTL of `2 hours`, authentication would not be possible once 
this period had elapsed. 

This kind of role is not commonly used for long lived applications, it is more
suitable to short lived processes like batch jobs or CI/CD. For our example, 
and to illustrate a point, it is however perfect.

<VSCodeTerminal target="Vault">
  <Command>
    vault write auth/approle/role/payments \
      secret_id_ttl=2h \
      token_max_ttl=2h \
      policies=payments
  </Command>
</VSCodeTerminal>

```shell
vault write auth/approle/role/payments \
    secret_id_ttl=2h \
    token_max_ttl=2h \
    policies=payments
```

Now that is configured let's see how it can be used to generate a role-id
and a secret-id so that Vault Agent can authenticate.

## Generating AppRole IDs and Secrets

To generate the role id you can run the following command. Role IDs are long
lived identifier for your application. 

<VSCodeTerminal target="Vault">
  <Command>
    vault read auth/approle/role/payments/role-id
  </Command>
</VSCodeTerminal>

```shell
vault read auth/approle/role/payments/role-id
```

```
Key        Value
---        -----
role_id    a00580d3-9e7d-de61-ba0b-a08c5b065595
```

Vault Agent needs to read this ID from a file, so let's output this to a
file called `.role-id`.

<VSCodeTerminal target="Vault">
  <Command>
    vault read --format=json \
      auth/approle/role/payments/role-id \
      | jq -r '.data.role_id' \
      > .role-id
  </Command>
</VSCodeTerminal>

```shell
vault read --format=json \
  auth/approle/role/payments/role-id \
  | jq -r '.data.role_id' \
  > .role-id
```

If you examine the file that has been just created you will see that the
file contains the same role-id that was created the first time you ran
the command.

<VSCodeTerminal target="Vault">
  <Command>cat .role-id</Command>
</VSCodeTerminal>

```shell
cat role-id
```

Next step is to generate the secret-id

<VSCodeTerminal target="Vault">
  <Command>vault write -f auth/approle/role/payments/secret-id</Command>
</VSCodeTerminal>

```shell
vault write -f auth/approle/role/payments/secret-id
```

```shell
Key                   Value
---                   -----
secret_id             b849bc50-46e4-bafc-5ae4-38a37b5b2dd3
secret_id_accessor    59355b7d-1499-7538-4be3-d4b8ee910066
secret_id_num_uses    0
secret_id_ttl         2h
```

The secret-id will be different every time you run this command. Let's run
this again but this time extracting the `secret_id` into a file `.secret-id`.

<VSCodeTerminal target="Vault">
  <Command>
    vault write -f --format=json \
      auth/approle/role/payments/secret-id \
      | jq -r '.data.secret_id' \
      > .secret-id
  </Command>
</VSCodeTerminal>

```shell
vault write -f --format=json \
  auth/approle/role/payments/secret-id \
  | jq -r '.data.secret_id' \
  > .secret-id
```

If you cat the file you will see the secret-id has been successfully written.

<VSCodeTerminal target="Vault">
  <Command>cat .secret-id</Command>
</VSCodeTerminal>

```shell
cat .secret-id
```

Now the authentication has been setup, let's configure Vault Agent to retrieve
your secrets.