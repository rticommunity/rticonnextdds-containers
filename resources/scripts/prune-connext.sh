#!/usr/bin/env bash
set -Eeuo pipefail

flavor="${1:?usage: prune-connext.sh <runtime|ui-tools>}"
root="${NDDSHOME:?NDDSHOME must be set}"

# Keep the runtime libraries, environment scripts, and license handling files.
# Development-only content is removed in the source stage so it never becomes a
# layer of the final image.
rm -rf \
    "${root}/doc" \
    "${root}/include" \
    "${root}/uninstall" \
    "${root}/resource/doc" \
    "${root}/resource/template" \
    "${root}/resource/idl" \
    "${root}/resource/cmake" \
    "${root}/resource/schema" \
    "${root}/resource/xml"

find "${root}/lib" -type f \( -name '*.a' -o -name '*d.so' -o -name '*zd.a' \) -delete

case "${flavor}" in
    runtime)
        # Runtime installs rti.connext from PyPI when the Python profile is
        # selected, so the platform-specific source wheels are not needed.
        rm -rf "${root}/resource/app" "${root}/resource/python_api"
        find "${root}/bin" -mindepth 1 ! -name rtientrypoint -delete
        ;;
    ui-tools)
        # UI Tools does not install rti.connext from PyPI; retain the packaged
        # wheels for Python-backed UI functionality.
        :
        ;;
    *)
        printf 'Unsupported prune flavor: %s\n' "${flavor}" >&2
        exit 2
        ;;
esac
