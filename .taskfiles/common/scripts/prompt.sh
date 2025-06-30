#!/bin/sh
# scripts/prompt.sh — POSIX-compliant prompt for $VAR_NAME, then run $VAR_CMD

# fail fast on unset variables or errors
set -eu

# ensure VAR_NAME is set
: "${VAR_NAME:?VAR_NAME is required}"

# grab current value of the named var
eval "value=\${$VAR_NAME}"

# if empty, prompt the user
if [ -z "$value" ]; then
  printf 'Enter value for %s: ' "$VAR_NAME" >&2
  stty -echo
  read -r value
  stty echo
  printf '\n' >&2
fi

# export the final value and run the command
eval "export $VAR_NAME=\"\$value\""
eval "$VAR_CMD"
