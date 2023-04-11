---
title: Static secrets 
sidebar_label: Static Secrets
---

The kv secrets engine is a generic Key-Value store used to store arbitrary 
secrets in Vault. This backend can be run in one of two modes; `kv version 1`
that allows a single value for a key and `kv version 2` that allows multiple 
versions for a keys value.


## KV Version 1
When running the kv secrets backend `version 1`, only the most recently written 
value for a key will be preserved. The benefits of `kv version 1` are reduced 
storage size and increased performance.  

More information about running in this mode can be found in the 
[K/V Version 1 Docs](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v1)

## KV Version 2

When running `version 2` of the kv backend a key can retain a configurable number 
of versions.  By default 10 version of a value for a key are stored, writing 
to the `kv` does not overwrite the value as it does with `kv version 1`, instead
a new version is created. Using `kv version 2` you not only maintain a partial
history for your secret, but you can also roll back a secret to a previous
version. This capability comes at a cost of increased storage,  are operations
are less performant due to increased activity on the storage engine.

More information about running in this mode can be found in the 
[K/V Version 2 Docs](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2)

Let's now see how the `kv version 1` engine works in practice.