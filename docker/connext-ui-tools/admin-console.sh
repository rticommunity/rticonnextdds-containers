#!/usr/bin/env bash
set -Eeuo pipefail
exec /usr/local/bin/rtientrypoint "${NDDSHOME}/bin/rtiadminconsole" "$@"
