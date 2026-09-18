#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
venv="${repo_root}/.ci-venv"

if [ -x "${venv}/bin/python" ] && "${venv}/bin/python" -c \
    'import pexpect, pytest; assert pexpect.__version__ == "4.9.0"; assert pytest.__version__ == "8.4.2"' \
    >/dev/null 2>&1; then
    printf "%s/bin/python\n" "${venv}"
    exit 0
fi

python3 -m venv "${venv}"
"${venv}/bin/python" -m pip install -r "${repo_root}/tests/requirements-test.txt" >/dev/null

printf "%s/bin/python\n" "${venv}"
