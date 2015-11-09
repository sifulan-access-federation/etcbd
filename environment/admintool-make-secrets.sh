#!/bin/bash

# Generate a Kubernetes Secrets descriptor with an envvars setting compiled out
# of given envvar files.
#
# The envvar file should follow the same Docker syntax (no quotes), and must be
# base64 encoded in the secrets file.
#
# Names of files to be provided on the command-line.
# Filter out empty lines and comments, but do not change the syntax.

cat <<-EOF
apiVersion: v1
kind: Secret
metadata:
  name: admintool-secrets
type: Opaque
data:
  envvars: `cat "$@" | grep -v '^$' | grep -v '^ *#' | base64`
EOF
