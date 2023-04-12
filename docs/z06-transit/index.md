---
title: Transit Secrets
sidebar_label: Transit Secrets
---

You can think about the Transit secrets engine in Vault as `cryptography as a service`.
It allows you to use Vault's to encrypt and decrypt arbitrary information, generate
and compare Hashes, HMACs and more.

When using the Transit secrets engine Vault does not store the data that you send
to it, it does however manage any cryptographic keys that are used.

It is a convenient and secure way for your applications to perform functions
that require encryption of data at rest, such as partial database encryption.

Let's work through some examples and see how this works.