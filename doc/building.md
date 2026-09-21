# Building Connext Images

Run all commands from the repository root. These Dockerfiles are provided for
local builds; RTI does not provide prebuilt images for these targets here.
Docker must include Buildx/Bake. Compose examples also require Docker Compose.

## Targets and Tags

| Bake target | Default local tag |
| --- | --- |
| sdk | local/connext-sdk:7.7.0 |
| runtime-all | local/connext-runtime:7.7.0 |
| runtime-c | local/connext-c-runtime:7.7.0 |
| runtime-cpp | local/connext-cpp-runtime:7.7.0 |
| runtime-java | local/connext-java-runtime:7.7.0 |
| runtime-csharp | local/connext-csharp-runtime:7.7.0 |
| runtime-python | local/connext-python-runtime:7.7.0 |
| ui-tools | local/connext-ui-tools:7.7.0 |

The default group builds `sdk` and `runtime-all`. The `all` group also builds
every Runtime variant and UI Tools. The `ui-test` group adds the RDP test client,
which is a test fixture, not a product image in the catalog.

```sh
docker buildx bake --print all
docker buildx bake --load sdk
docker buildx bake --load runtime-cpp
docker buildx bake --load ui-tools
```

SDK includes all supported language build dependencies. Only Runtime selects
languages. Custom combinations can override a target:

```sh
docker buildx bake --load runtime-all \
  --set runtime-all.args.CONNEXT_LANGUAGES=cpp,python \
  --set runtime-all.tags=local/connext-runtime:7.7.0-cpp-python
```

## Configuration

[docker-bake.hcl](../docker-bake.hcl) defines `CONNEXT_VERSION` (default `7.7.0`),
`BASE_IMAGE` (`rticom/connext-base:7.7.0`), `DOCKER_PLATFORM` (default `linux/amd64`),
`IMAGE_TAG_PREFIX` (default `local`) and optional `IMAGE_TAG_SUFFIX`.
Override these variables through the environment or a Bake override file.

SDK and Runtime support `linux/amd64` and `linux/arm64`; an emulated build needs
Docker platform emulation. UI Tools and its RDP test client are amd64-only and
ignore `DOCKER_PLATFORM`. UI Tools uses its own digest-pinned desktop base.

The SDK/Runtime Dockerfiles also accept `DOTNET_VERSION` and
`RTI_CONNEXT_PYTHON_PACKAGE_VERSION`. Changing language runtime versions requires
compatible examples; C# tests currently target .NET 10.

## Installation

The SDK, Runtime and UI Tools Dockerfiles copy Connext from the public
`rticom/connext-base:7.7.0` image. Runtime content is pruned before it is copied
into a clean Ubuntu image; UI Tools content is pruned before it is copied into
the desktop image. Language and desktop dependencies are installed from their
respective official package repositories by
[install-language-dependencies.sh](../resources/scripts/install-language-dependencies.sh)
and the UI Dockerfile.

Builds accept RTI's license agreement for unattended installation. A license
file for application execution must remain external and be mounted read-only.
Build dependencies can change over time. Build metadata provides traceability,
not a complete dependency lock. Pin reviewed base images and package versions
when exact reproduction is required, and update pins for security fixes.
