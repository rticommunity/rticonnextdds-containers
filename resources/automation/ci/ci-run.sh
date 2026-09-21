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
RUN_UI_TOOLS="${RUN_UI_TOOLS:-true}"
RUN_RUNTIME_EXAMPLES="${RUN_RUNTIME_EXAMPLES:-false}"
RTI_LICENSE_FILE_HOST="${RTI_LICENSE_FILE_HOST:-${RTI_LICENSE_FILE_PATH:-}}"
PYTHON_TEST_BIN="${PYTHON_TEST_BIN:-}"
KEEP_CI_IMAGES="${KEEP_CI_IMAGES:-false}"
MAX_RUNTIME_IMAGE_SIZE_MB="${MAX_RUNTIME_IMAGE_SIZE_MB:-0}"
CI_LANGUAGE_PROFILES="${CI_LANGUAGE_PROFILES:-all c cpp java csharp python}"

./resources/automation/ci/ci-check.sh

if [ "${RUN_RUNTIME_EXAMPLES}" = true ] && [ ! -f "${RTI_LICENSE_FILE_HOST}" ]; then
    printf 'Runtime and GUI execution require a readable license file.\n' >&2
    exit 1
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
