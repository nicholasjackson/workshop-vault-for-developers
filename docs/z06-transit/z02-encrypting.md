---
title: Encrypting and Decrypting Data
sidebar_label: Encrypting and Decrypting Data
---

To encrypt or decrypt data with the Transit secrets engine you first 
need to generate a key.

## Generating Keys

Generating a key is done using the `vault write` command to the path 
`transit/keys/[keyname]`. By default you do not need to specify any parameters;
generating a key with no parameters will generate you an `aes256-gcm96`.
Like the example below, you can optional specify the key type that you would
like to use, in this example you will specify the `rsa4096` key.

Generally the key type is consideration of performance and the level of security
that you need from the encrypted data. Vault manages the encryption process
and unless specified in the key generation process does not allow you access
to the raw encryption key.

https://developer.hashicorp.com/vault/api-docs/secret/transit#parameters

Run this command now to generate an `RSA 4096` bit key for the `payments`
application.

<VSCodeTerminal target="Vault">
  <Command>
  vault write transit/keys/payments type=rsa-4096
  </Command>
</VSCodeTerminal>

```shell
vault write transit/keys/payments type=rsa-4096
```

```
Success! Data written to: transit/keys/payments
```

Notice that Vault does not give you a copy of the key, it stores it securely
in its internal database.

## Encrypting data with the transit secrets engine

Let's see how you can use the Transit secrets engine to encrypt data.

The transit secrets engine can encrypt any kind of data including binary files.
However; to ensure that the API can read the data you should always base64
encode the data before sending it to Vault.

The below command encrypts the data `1234-1234-1234-1234` using the `payments`
key that you create earlier.

Run this command now and take a look at the output.

<VSCodeTerminal target="Vault">
  <Command>
  vault write transit/encrypt/payments plaintext=$(echo "1234-1234-1234-1234" | base64)
  </Command>
</VSCodeTerminal>

```shell
vault write transit/encrypt/payments plaintext=$(echo "1234-1234-1234-1234" | base64)
```

You should see some output that looks like the following

```
Key            Value
---            -----
ciphertext     vault:v1:XOWR223PRnyI3TeQPw16kOIse1R0OuIRwdB0tVOjZ1X0poHymF7DR0XANSBkR5ma1XDo4eR7s1Sst3wNwaJn8uehITiGZJ9A/k3W3p9iv6Wa5Swy2WvItLIhYRNRssnO6E5krf/dwQIA7FBfzUODvQ90deLZXMchMgwtcZf/lq+hJQWJ68n6mG+ifcsGH7vwHyFA1zqAVWvO70KNVWRqNIQINzzIrIqCCryS9CDv0VIur1YqyfCRvb9pwRJHe20m0zhkAST0dhb0XibcuHyqOV2J32UrMluIJsN+Wd1fRta9c5hJ1AWI7wJd488kDYC22jWferPzobEviiR2MW512ANjmwb2R6sHEXRjLwos0RVt+CO0CPN7OlyYAO4ABDt4lwzHl9Dnon7t00wHyO1KRXhJ74rth1BrMwj3GmM5l35UqC13a0uX2RRR+bcEFH9wzFXzgO/wgSw5PaIaLR5MkygexermwBXmhb8VAxXXYBsVcT7qHO0bqOZQfyJ+9eh6L35TYcRLkF16R7hSl+lFycJyO9iL7TLWnAKtYMMQtKOYT3VLrV8wBPEqS+gC0kQSovcsXAcPVgvBgsI+h5DKXIiCVFiZykVj/8trWUEevW1cDMF5bs31TILPWaZu7Hc5UAdx7BQP8NMGueNAjNLRYYrJSWimq/NlFrKiVCNp/y4=
key_version    1
```

To make it easy to decrypt the data, let's run that command again but store
the cipher text in the file encrypted.txt

### Challenge

I will leave this step up to you to figure out, it is a similar process that
you have done many times through the course of this workshop.

<details>
  <summary>Answer</summary>

Did you manage that?

You should have run the following command:

<VSCodeTerminal target="Vault">
  <Command>
  vault write \
    -format=json \
    transit/encrypt/payments \
    plaintext=$(echo "1234-1234-1234-1234" | base64) \
    | jq -r .data.ciphertext \
    > encrypted.txt
  </Command>
</VSCodeTerminal>

```shell
vault write \
  -format=json \
  transit/encrypt/payments \
  plaintext=$(echo "1234-1234-1234-1234" | base64) \
  | jq -r .data.ciphertext \
  > encrypted.txt
```
</details>

With the ciphertext stored in the `encrypted.txt` file you can now use the 
transit secrets engine to decrypt this data.

## Decrypting data with transit secrets engine

Run the following command to decrypt the data that you encrypted in an 
earlier step.

<VSCodeTerminal target="Vault">
  <Command>
    vault write transit/decrypt/payments ciphertext=$(cat encrypted.txt)
  </Command>
</VSCodeTerminal>

```shell
vault write transit/decrypt/payments ciphertext=$(cat encrypted.txt)
```

You will see some output that looks like the following, the decrypted
data is base64 encoded.

```
Key          Value
---          -----
plaintext    MTIzNC0xMjM0LTEyMzQtMTIzNAo=
```

Let's use a little `jq` magic to parse that and return the plain text

<VSCodeTerminal target="Vault">
  <Command>
    vault write \
      --format=json \
      transit/decrypt/payments \
      ciphertext=$(cat encrypted.txt) \
      | jq -r .data.plaintext \
      | base64 -d
  </Command>
</VSCodeTerminal>

```shell
vault write \
  --format=json \
  transit/decrypt/payments \
  ciphertext=$(cat encrypted.txt) \
  | jq -r .data.plaintext \
  | base64 -d
```

You should see the following output from the command.

```
1234-1234-1234-1234
```

Before you learn how to integrate this into your applications, let's see
how you can use the same process to generate HMACs from your data.

## Generating HMACs

A Hash Based Message Authentication Code (HMAC) creates a signature for 
a piece of data using a cryptographic hash and symetrical encryption using 
an encryption key. It provides lower computation and greater speed over
hashing algorythms like bcrypt and scrypt at the expense of requiring 
an encryption key to be share between systems that hash data and those which
verify the data.

### Challenge

Why don't you spend 5 minutes and use Vault to HMAC the following message.

```shell
But a person is not made for defeat. A person can be destroyed but not defeated.

---
Ernest Hemingway
```

You can find the documentation for HMAC at the following location:

https://developer.hashicorp.com/vault/api-docs/secret/transit#generate-hmac

For convenience a text file containing the message is stored in `message.txt`

<details>
  <summary>Answer</summary>

Did you solve the problem?

Your solution should look something like the following.

<VSCodeTerminal target="Vault">
  <Command>
    vault write \
      transit/hmac/payments \
      input=$(cat message.txt | base64)
  </Command>
</VSCodeTerminal>

```shell
vault write \
  transit/hmac/payments \
  input=$(cat message.txt | base64)
```

```shell
Key     Value
---     -----
hmac    vault:v1:6ok9429ec8BGq5RIaIhHHNwmc3KnjdCPPKhmHdJ/DIc=
``` 
</details>

Let's now see how transit can be used with the example application.
