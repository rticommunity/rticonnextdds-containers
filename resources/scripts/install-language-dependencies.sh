#!/usr/bin/env bash
set -Eeuo pipefail

image_flavor="${1:?usage: install-language-dependencies.sh <sdk|runtime> [languages]}"
languages="${2:-${CONNEXT_LANGUAGES:-all}}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/language-utils.sh"

CONNEXT_VERSION="${CONNEXT_VERSION:-7.7.0}"
PREFIX="${PREFIX:-/opt/rti.com}"
DOTNET_VERSION="${DOTNET_VERSION:-10.0}"
MICROSOFT_PACKAGES_URL="${MICROSOFT_PACKAGES_URL:-}"
RTI_CONNEXT_PYTHON_PACKAGE_VERSION="${RTI_CONNEXT_PYTHON_PACKAGE_VERSION:-${CONNEXT_VERSION}}"

apt_packages=()
needs_dotnet=false
needs_python_api=false

add_packages() {
    apt_packages+=("$@")
}

install_microsoft_packages_repository() {
    local ubuntu_version
    local packages_url

    ubuntu_version="$(. /etc/os-release && printf "%s" "${VERSION_ID}")"
    packages_url="${MICROSOFT_PACKAGES_URL:-https://packages.microsoft.com/config/ubuntu/${ubuntu_version}/packages-microsoft-prod.deb}"

    apt-get update
    apt-get install -y --no-install-recommends ca-certificates curl
    curl -fsSL -o /tmp/packages-microsoft-prod.deb "${packages_url}"
    dpkg -i /tmp/packages-microsoft-prod.deb
    rm -f /tmp/packages-microsoft-prod.deb
}

install_python_api() {
    local venv="${PREFIX}/python-venv"
    local package="rti.connext"

    if [ -n "${RTI_CONNEXT_PYTHON_PACKAGE_VERSION}" ]; then
        package="${package}==${RTI_CONNEXT_PYTHON_PACKAGE_VERSION}"
    fi

    python3 -m venv "${venv}"
    "${venv}/bin/pip" install --no-cache-dir "${package}"
}

case "${image_flavor}" in sdk|runtime) ;; *) exit 2 ;; esac
normalized_languages="$(normalize_connext_languages "${languages}")"
while IFS= read -r language; do
    case "${language}" in
        c)
            if [ "${image_flavor}" = "sdk" ]; then
                add_packages build-essential make
            fi
            ;;
        cpp)
            if [ "${image_flavor}" = "sdk" ]; then
                add_packages build-essential cmake make
            else
                add_packages libstdc++6
            fi
            ;;
        java)
            if [ "${image_flavor}" = "sdk" ]; then
                add_packages openjdk-11-jdk-headless make
            else
                add_packages openjdk-11-jre-headless
            fi
            ;;
        csharp)
            needs_dotnet=true
            if [ "${image_flavor}" = "sdk" ]; then
                add_packages "dotnet-sdk-${DOTNET_VERSION}"
            else
                add_packages "dotnet-runtime-${DOTNET_VERSION}"
            fi
            ;;
        python)
            needs_python_api=true
            if [ "${image_flavor}" = "sdk" ]; then
                add_packages python3 python3-pip python3-venv
            else
                add_packages python3 python3-venv
            fi
            ;;
    esac
done <<< "${normalized_languages}"

export DEBIAN_FRONTEND=noninteractive

if [ "${needs_dotnet}" = "true" ]; then
    install_microsoft_packages_repository
fi

if [ "${#apt_packages[@]}" -gt 0 ]; then
    mapfile -t apt_packages < <(printf "%s\n" "${apt_packages[@]}" | awk '!seen[$0]++')
    apt-get update
    apt-get install -y --no-install-recommends "${apt_packages[@]}"
fi

if [ "${needs_python_api}" = "true" ]; then
    install_python_api
fi

apt-get clean
rm -rf /var/lib/apt/lists/* /root/.cache/pip
