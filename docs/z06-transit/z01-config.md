---
title: Enabling Transit Secrets
sidebar_label: Enabling Transit Secrets
---

Like all secrets engines in Vault you first need to enable it, run the following
command to enable the engine.

<VSCodeTerminal target="Vault">
  <Command>vault secrets enable transit</Command>
</VSCodeTerminal>

``` shell
vault secrets enable transit
```

```shell
Success! Enabled the transit secrets engine at: transit/
```

Unlike other engines there is no configuration, you create keys and then use
them to perform cryptographic operations. Let's dive in an see that in action.
