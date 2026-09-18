#!/usr/bin/env bash
set -Eeuo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${repo_root}"
export IMAGE_TAG_SUFFIX="${IMAGE_TAG_SUFFIX:-run-$(date '+%Y-%m-%d_%H-%M-%S')}"
NO_CACHE="${NO_CACHE:-false}"
PYTHON_TEST_BIN="${PYTHON_TEST_BIN:-$(./resources/automation/ci/setup-python-test-env.sh)}"
reports="$(pwd)/reports/${IMAGE_TAG_SUFFIX}/ui-tools"
mkdir -p "$reports"
docker buildx bake --print ui-test > "$reports/bake.json"
image="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["target"]["ui-tools"]["tags"][0])' "$reports/bake.json")"
rdp_client_image="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["target"]["rdp-test-client"]["tags"][0])' "$reports/bake.json")"
cleanup() {
    if [ "${KEEP_CI_IMAGES:-false}" != true ]; then
        docker image rm "$image" "$rdp_client_image" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM
bake_args=(--load --metadata-file "$reports/build.json")
if [ "$NO_CACHE" = true ]; then
    bake_args+=(--no-cache)
fi
docker buildx bake "${bake_args[@]}" ui-test
docker image inspect "$image" "$rdp_client_image" > "$reports/images.json"
args=(--image "$image" --rdp-client-image "$rdp_client_image" --reports "$reports")
if [ "${RUN_RUNTIME_EXAMPLES:-false}" = true ]; then
    args+=(--license-file "${RTI_LICENSE_FILE_HOST:?A license is required for the GUI test}")
fi
"${PYTHON_TEST_BIN}" -m pytest -c "${repo_root}/tests/pytest.ini" -q --junitxml "$reports/ui-tools.xml" \
    -o "junit_suite_name=UI tools" tests/ui_tools_test.py "${args[@]}"
