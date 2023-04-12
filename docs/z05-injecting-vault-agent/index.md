---
title: Injecting Secrets With Vault Agent
sidebar_label: Injecting Secrets With Vault Agent
---

Let's now see how you can provide all the different types of secrets that
you have created so far to your application.

In this section you will learn how to use Vault Agent which is a Vault tool
that manages authentication and secrets access enabling you to automatically
generate machine specific configuration for your applications.

When you worked through the exercises for injecting secrets to Kubernetes
you were actually using Vault Agent. The Kubernetes controller automates
much of the setup but under the hood, it is Vault Agent that is generating
your secret config.

The Vault Agent documentation can be found at the following link, spend 
a couple of minutes familiarizing your self with it before continuing.

https://developer.hashicorp.com/vault/docs/agent