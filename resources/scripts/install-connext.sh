#!/usr/bin/env bash
set -Eeuo pipefail

image_flavor="${1:-${CONNEXT_IMAGE_FLAVOR:-sdk}}"

CONNEXT_VERSION="${CONNEXT_VERSION:-7.7.0}"
CONNEXT_INSTALL_METHOD="${CONNEXT_INSTALL_METHOD:-apt}"
PREFIX="${PREFIX:-/opt/rti.com}"
NDDSHOME="${NDDSHOME:-${PREFIX}/rti_connext_dds-${CONNEXT_VERSION}}"
RTI_APT_REPOSITORY_URL="${RTI_APT_REPOSITORY_URL:-https://packages.rti.com/deb/official}"
RTI_APT_KEY_URL="${RTI_APT_KEY_URL:-${RTI_APT_REPOSITORY_URL}/repo.key}"
RTI_APT_KEYRING="${RTI_APT_KEYRING:-/usr/share/keyrings/rti-official-archive.gpg}"
RTI_LICENSE_AGREEMENT_ACCEPTED="${RTI_LICENSE_AGREEMENT_ACCEPTED:-accepted}"

install_apt_prerequisites() {
    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        debconf
    rm -rf /var/lib/apt/lists/*
}

configure_rti_apt_repository() {
    local distro_codename
    local architecture

    distro_codename="$(. /etc/os-release && printf "%s" "${VERSION_CODENAME}")"
    architecture="$(dpkg --print-architecture)"

    curl -fsSL -o "${RTI_APT_KEYRING}" "${RTI_APT_KEY_URL}"
    printf "deb [arch=%s, signed-by=%s] %s %s main\n" \
        "${architecture}" \
        "${RTI_APT_KEYRING}" \
        "${RTI_APT_REPOSITORY_URL}" \
        "${distro_codename}" \
        > /etc/apt/sources.list.d/rti-official.list
}

default_apt_packages() {
    case "${image_flavor}" in
        sdk)
            printf "rti-connext-dds-%s-lib-dev\n" "${CONNEXT_VERSION}"
            printf "rti-connext-dds-%s-rtiddsgen\n" "${CONNEXT_VERSION}"
            ;;
        runtime)
            printf "rti-connext-dds-%s-lib\n" "${CONNEXT_VERSION}"
            ;;
        ui-tools)
            printf "rti-connext-dds-%s-tools-all\n" "${CONNEXT_VERSION}"
            ;;
        *)
            printf "Unknown Connext image flavor: %s\n" "${image_flavor}" >&2
            exit 2
            ;;
    esac
}

install_connext_from_apt() {
    local package_list

    install_apt_prerequisites
    configure_rti_apt_repository

    printf "rti-connext-dds-%s-common rti-connext-dds-%s/license/accepted select true\n" \
        "${CONNEXT_VERSION}" \
        "${CONNEXT_VERSION}" \
        | debconf-set-selections

    export DEBIAN_FRONTEND=noninteractive
    export RTI_LICENSE_AGREEMENT_ACCEPTED

    apt-get update
    if [ -n "${CONNEXT_APT_PACKAGES:-}" ]; then
        # shellcheck disable=SC2086
        apt-get install -y --no-install-recommends ${CONNEXT_APT_PACKAGES}
    else
        package_list="$(default_apt_packages | xargs)"
        # shellcheck disable=SC2086
        apt-get install -y --no-install-recommends ${package_list}
    fi
    rm -rf /var/lib/apt/lists/*
}

install_connext_from_run_installer() {
    printf "CONNEXT_INSTALL_METHOD=run-installer is intentionally a placeholder.\n" >&2
    printf "Add installer and rtipkg handling here when public installer builds are enabled.\n" >&2
    exit 2
}

case "${CONNEXT_INSTALL_METHOD}" in
    apt)
        install_connext_from_apt
        ;;
    run-installer)
        install_connext_from_run_installer
        ;;
    *)
        printf "Unsupported CONNEXT_INSTALL_METHOD: %s\n" "${CONNEXT_INSTALL_METHOD}" >&2
        exit 2
        ;;
esac

if [ ! -d "${NDDSHOME}" ]; then
    printf "Expected Connext installation directory was not found: %s\n" "${NDDSHOME}" >&2
    exit 1
fi
