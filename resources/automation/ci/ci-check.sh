#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${repo_root}"

# Validate every shell script so newly added scripts are covered automatically.
while IFS= read -r -d '' script; do
    bash -n "${script}"
done < <(find . \( -path './.git' -o -path './.ci-venv' -o -path './reports' \) -prune -o \
    -type f -name '*.sh' -print0)

# Validate Python syntax across the repository without maintaining a file list.
while IFS= read -r -d '' source_file; do
    python3 -m py_compile "${source_file}"
done < <(find . \( -path './.git' -o -path './.ci-venv' -o -path './reports' \) -prune -o \
    -type f -name '*.py' -print0)

# Check that language profile helpers reject invalid and empty input.
source resources/scripts/language-utils.sh
# An unknown profile must fail instead of silently selecting a configuration.
if connext_example_languages invalid-profile >/dev/null 2>&1; then
    printf "Invalid language profile was accepted.\n" >&2
    exit 1
fi
# Whitespace-only input must fail instead of producing an empty test matrix.
if normalize_connext_languages "   " >/dev/null 2>&1; then
    printf "Empty language selection was accepted.\n" >&2
    exit 1
fi

printf "Repository checks passed.\n"
