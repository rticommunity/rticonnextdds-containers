#!/usr/bin/env bash
set -Eeuo pipefail
password_file="${UI_PASSWORD_FILE:-/run/secrets/ui_password}"
if [ ! -r "$password_file" ]; then
    printf 'A readable UI_PASSWORD_FILE is required.\n' >&2
    exit 2
fi
password="$(cat "$password_file")"
if [ -z "$password" ] || [ "$password" = password ] || [[ "$password" == *$'\n'* ]]; then
    printf 'Provide a non-default, non-empty, single-line desktop password.\n' >&2
    exit 2
fi
export UNPRIVILEGED_USER_PASSWORD="$password"
exec /usr/local/bin/container-init "$@"
