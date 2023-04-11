---
title: x509 Certificates
sidebar_label: x509 Certificates
---

Let's now take a look at how you can use Vault to generate x590 certificates
for your applications.

In this section we will move slightly away from Kubernetes and look at how
applications that may be running on a Virtual Machine can leverage Vault.

All the things that you will learn in this section are transferrable to 
Kubernetes so if you only deploy your applications this way there is still
much to learn.

Let's get started and see how you configure the `pki` engine in Vault that
can be used to generate x509 certificates. 