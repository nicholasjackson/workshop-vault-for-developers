---
title: x509 Certificates
sidebar_label: x509 Certificates
---

Writing static secrets

<VSCodeTerminal target="Terminal 1">
  <Command>vault status</Command>
</VSCodeTerminal>

```
vault kv put secret/web payments_api_key=abcdefg
```

<p></p>

Reading static secrets

```
vault kv get secret/web
```

<p></p>