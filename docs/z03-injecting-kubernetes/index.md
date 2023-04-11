---
title: Injecting Secrets to Kubernetes Deployments
sidebar_label: Injecting Secrets to Kubernetes
---

Now you have learned about the KV Version 1 and Version 2, let's see how you
can use these secrets with Kubernetes.

First you need to configure Vault's authentication so that your deployments
can access a secret. While configuration of authentication might not be 
seen as a traditional developer task. It is useful to understand how this 
process works so that you can successfully debug your workloads.