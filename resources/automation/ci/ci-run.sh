#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${repo_root}"

CONNEXT_VERSION="${CONNEXT_VERSION:-7.7.0}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"
IMAGE_TAG_PREFIX="${IMAGE_TAG_PREFIX:-local}"
IMAGE_TAG_SUFFIX="${IMAGE_TAG_SUFFIX:-run-$(date '+%Y-%m-%d_%H-%M-%S')}"
RUN_DOCKERFILE_CHECKS="${RUN_DOCKERFILE_CHECKS:-true}"
RUN_LANGUAGE_MATRIX="${RUN_LANGUAGE_MATRIX:-true}"
RUN_RUNTIME_EXAMPLES="${RUN_RUNTIME_EXAMPLES:-true}"
RTI_LICENSE_FILE_HOST="${RTI_LICENSE_FILE_HOST:-${RTI_LICENSE_FILE_PATH:-}}"
PYTHON_TEST_BIN="${PYTHON_TEST_BIN:-}"
KEEP_CI_IMAGES="${KEEP_CI_IMAGES:-false}"
MAX_RUNTIME_IMAGE_SIZE_MB="${MAX_RUNTIME_IMAGE_SIZE_MB:-0}"
CI_LANGUAGE_PROFILES="${CI_LANGUAGE_PROFILES:-all c cpp java csharp python}"

if [ -z "${RUN_UI_TOOLS+x}" ]; then
    case "${DOCKER_PLATFORM}" in
        linux/arm64*) RUN_UI_TOOLS=false ;;
        *) RUN_UI_TOOLS=true ;;
    esac
fi

./resources/automation/ci/ci-check.sh

if [ "${RUN_RUNTIME_EXAMPLES}" = true ]; then
    if [ -z "${RTI_LICENSE_FILE_HOST}" ] || \
        [ ! -f "${RTI_LICENSE_FILE_HOST}" ] || \
        [ ! -r "${RTI_LICENSE_FILE_HOST}" ]; then
        printf 'RTI license file not found or not readable. Set RTI_LICENSE_FILE_HOST to a valid file. Obtain a license at: https://evaluation.rti.com/\n' >&2
        exit 1
    fi
fi

if [ "${RUN_DOCKERFILE_CHECKS}" = "true" ]; then
    docker buildx bake --check all ui-test
fi

status=0
if [ "${RUN_LANGUAGE_MATRIX}" = "true" ]; then
    if [ "${RUN_RUNTIME_EXAMPLES}" = "true" ] && [ -z "${PYTHON_TEST_BIN}" ]; then
        PYTHON_TEST_BIN="$(./resources/automation/ci/setup-python-test-env.sh)"
    fi

    CONNEXT_VERSION="${CONNEXT_VERSION}" \
    DOCKER_PLATFORM="${DOCKER_PLATFORM}" \
    IMAGE_TAG_PREFIX="${IMAGE_TAG_PREFIX}" \
    IMAGE_TAG_SUFFIX="${IMAGE_TAG_SUFFIX}" \
    RUN_RUNTIME_EXAMPLES="${RUN_RUNTIME_EXAMPLES}" \
    RTI_LICENSE_FILE_HOST="${RTI_LICENSE_FILE_HOST}" \
    PYTHON_TEST_BIN="${PYTHON_TEST_BIN}" \
    KEEP_CI_IMAGES="${KEEP_CI_IMAGES}" \
    MAX_RUNTIME_IMAGE_SIZE_MB="${MAX_RUNTIME_IMAGE_SIZE_MB}" \
    CI_LANGUAGE_PROFILES="${CI_LANGUAGE_PROFILES}" \
        ./resources/automation/ci/ci-language-matrix.sh || status=1
fi

if [ "${RUN_UI_TOOLS}" = true ]; then
    CONNEXT_VERSION="${CONNEXT_VERSION}" IMAGE_TAG_PREFIX="${IMAGE_TAG_PREFIX}" \
    IMAGE_TAG_SUFFIX="${IMAGE_TAG_SUFFIX}" KEEP_CI_IMAGES="${KEEP_CI_IMAGES}" \
    RUN_RUNTIME_EXAMPLES="${RUN_RUNTIME_EXAMPLES}" RTI_LICENSE_FILE_HOST="${RTI_LICENSE_FILE_HOST}" \
        ./resources/automation/ci/ci-ui-tools.sh || status=1
fi
exit "$status"
