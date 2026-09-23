#!/usr/bin/env bash
set -Eeuo pipefail

SDK_IMAGE="${SDK_IMAGE:?SDK_IMAGE is required}"
RUNTIME_IMAGE="${RUNTIME_IMAGE:?RUNTIME_IMAGE is required}"
CONNEXT_LANGUAGES="${CONNEXT_LANGUAGES:-all}"
RUN_RUNTIME_EXAMPLES="${RUN_RUNTIME_EXAMPLES:-true}"
RTI_LICENSE_FILE_HOST="${RTI_LICENSE_FILE_HOST:-}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-}"
PYTHON_TEST_BIN="${PYTHON_TEST_BIN:-}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${repo_root}/resources/scripts/language-utils.sh"

if [ "${RUN_RUNTIME_EXAMPLES}" = "true" ] && [ -z "${PYTHON_TEST_BIN}" ]; then
    PYTHON_TEST_BIN="$(${repo_root}/resources/automation/ci/setup-python-test-env.sh)"
fi

languages="$(connext_example_languages "${CONNEXT_LANGUAGES}")"
report_dir="${TEST_REPORT_DIR:-${repo_root}/reports/examples}"
export TEST_REPORT_DIR="${report_dir}"
mkdir -p "${report_dir}"
workdir="${CI_EXAMPLE_WORKDIR:-$(mktemp -d)}"
chmod 0777 "$workdir"
cleanup() {
    if [ -z "${CI_EXAMPLE_WORKDIR:-}" ]; then rm -rf "${workdir}"; fi
}
trap cleanup EXIT

cp "${repo_root}/resources/idls/HelloWorld.idl" "${workdir}/HelloWorld.idl"

docker_platform_args=()

if [ -n "${DOCKER_PLATFORM}" ]; then
    docker_platform_args+=(--platform "${DOCKER_PLATFORM}")
fi

if [ "${RUN_RUNTIME_EXAMPLES}" = "true" ]; then
    if [ -z "${RTI_LICENSE_FILE_HOST}" ] || [ ! -f "${RTI_LICENSE_FILE_HOST}" ]; then
        printf "RUN_RUNTIME_EXAMPLES=true requires RTI_LICENSE_FILE_HOST to point to a readable license file.\n" >&2
        exit 1
    fi

fi

while IFS= read -r language; do
    if [ ! -f "${workdir}/${language}.built" ]; then
        printf "Building HelloWorld for %s with %s\n" "${language}" "${SDK_IMAGE}"
        if ! docker run --rm \
            "${docker_platform_args[@]+${docker_platform_args[@]}}" \
            --user "$(id -u):$(id -g)" \
            --env HOME=/tmp \
            --volume "${workdir}:/work" \
            --volume "${repo_root}/resources/scripts:/repo/resources/scripts:ro" \
            "${SDK_IMAGE}" \
            /repo/resources/scripts/build-connext-example.sh "${language}" /work \
            > "${report_dir}/${language}-build.log" 2>&1; then
            cat "${report_dir}/${language}-build.log" >&2
            exit 1
        fi
        touch "${workdir}/${language}.built"
    else
        printf "Reusing HelloWorld build for %s\n" "${language}"
    fi

    if [ "${RUN_RUNTIME_EXAMPLES}" = "true" ]; then
        printf "Testing HelloWorld pub/sub for %s with %s\n" "${language}" "${RUNTIME_IMAGE}"
        "${PYTHON_TEST_BIN}" -m pytest -c "${repo_root}/tests/pytest.ini" -q \
            --junitxml "${report_dir}/${language}.xml" \
            --junit-prefix "${RUNTIME_IMAGE}" \
            -o "junit_suite_name=Connext" \
            "${repo_root}/tests/pubsub_test.py" \
            --runtime-image "${RUNTIME_IMAGE}" \
            --language "${language}" \
            --workdir "${workdir}" \
            --license-file "${RTI_LICENSE_FILE_HOST}" \
            --platform "${DOCKER_PLATFORM}"
    else
        printf "Skipping Runtime execution for %s because RUN_RUNTIME_EXAMPLES=false.\n" "${language}"
    fi
done <<< "${languages}"
