#!/bin/bash

code-server serve-local \
  --accept-server-license-terms \
  --connection-token ${AUTH_KEY} \
  --host 0.0.0.0 \
  --verbose