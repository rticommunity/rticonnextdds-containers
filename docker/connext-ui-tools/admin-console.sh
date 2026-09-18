#!/usr/bin/env bash
set -Eeuo pipefail
eval "$("rtienv-${CONNEXT_VERSION}")"
exec "${NDDSHOME}/bin/rtiadminconsole" "$@"
