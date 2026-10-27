#!/bin/sh
set -eu

pnpm prisma migrate deploy
node /app/scripts/migrate-config.js
node /app/scripts/hash-file-passwords.js
