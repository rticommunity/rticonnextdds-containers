#!/usr/bin/env bash
set -Eeuo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${repo_root}"
export IMAGE_TAG_SUFFIX="${IMAGE_TAG_SUFFIX:-run-$(date '+%Y-%m-%d_%H-%M-%S')}"
NO_CACHE="${NO_CACHE:-false}"
read -r -a profiles <<< "${CI_LANGUAGE_PROFILES:-all c cpp java csharp python}"
[ "${#profiles[@]}" -gt 0 ] || exit 2
targets=(sdk)
for profile in "${profiles[@]}"; do
    case "$profile" in all|c|cpp|java|csharp|python) ;; *) printf 'Invalid profile: %s\n' "$profile" >&2; exit 2 ;; esac
    targets+=("runtime-$profile")
done
reports="$(pwd)/reports/$IMAGE_TAG_SUFFIX"
mkdir -p "$reports"
docker buildx bake --print "${targets[@]}" > "$reports/bake.json"
image_for() {
    python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["target"][sys.argv[2]]["tags"][0])' "$reports/bake.json" "$1"
}
built_images=()
workdir="$(mktemp -d)"
chmod 0777 "$workdir"
cleanup() {
    rm -rf "$workdir"
    if [ "${KEEP_CI_IMAGES:-false}" != true ] && [ "${#built_images[@]}" -gt 0 ]; then
        docker image rm "${built_images[@]}" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM
bake_args=(--load --metadata-file "$reports/build.json")
if [ "$NO_CACHE" = true ]; then
    bake_args+=(--no-cache)
fi
docker buildx bake "${bake_args[@]}" "${targets[@]}"
for target in "${targets[@]}"; do built_images+=("$(image_for "$target")"); done
docker image inspect "${built_images[@]}" > "$reports/images.json"
sdk_image="$(image_for sdk)"
status=0
for profile in "${profiles[@]}"; do
    runtime_image="$(image_for "runtime-$profile")"
    size="$(docker image inspect "$runtime_image" --format '{{.Size}}')"
    size_mb="$(( (size + 1048575) / 1048576 ))"
    printf '%s: %s MiB\n' "$runtime_image" "$size_mb"
    if [ "${MAX_RUNTIME_IMAGE_SIZE_MB:-0}" -gt 0 ] && [ "$size_mb" -gt "$MAX_RUNTIME_IMAGE_SIZE_MB" ]; then
        printf 'Runtime size exceeds limit: %s > %s MiB\n' "$size_mb" "$MAX_RUNTIME_IMAGE_SIZE_MB" >&2
        status=1
    fi
    SDK_IMAGE="$sdk_image" RUNTIME_IMAGE="$runtime_image" CONNEXT_LANGUAGES="$profile" \
        CI_EXAMPLE_WORKDIR="$workdir" TEST_REPORT_DIR="$reports/$profile" \
        ./resources/automation/ci/test-connext-examples.sh || status=1
done
exit "$status"
