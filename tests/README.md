# Testing and CI

This directory contains the automated validation for the RTI Connext container
images.

## Run the checks

From the repository root, run the complete local validation with a readable RTI
license outside the repository:

```sh
RUN_RUNTIME_EXAMPLES=true \
RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat \
./resources/automation/ci/ci-run.sh
```

This validates the repository, Bake configuration, image builds, generated
examples, Runtime publisher/subscriber communication and the Admin Console UI.

## Platforms

The default SDK/Runtime matrix uses `linux/amd64`. For `linux/arm64`, run:

```sh
DOCKER_PLATFORM=linux/arm64 \
RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat \
./resources/automation/ci/ci-run.sh
```

Connext UI Tools are not supported on ARM. This test runs only the SDK and
Runtime validation on ARM64.

## CI Options

Tests require Bash and Python 3.9+ with venv/pip. The runner creates a local
environment with the pinned [test dependencies](requirements-test.txt).
The Docker daemon must see the bind-mount paths and its published loopback
ports must be reachable from the runner.

| Environment variable | Default | Purpose |
| --- | --- | --- |
| `CONNEXT_VERSION` | `7.7.0` | Connext version and image tags |
| `DOCKER_PLATFORM` | `linux/amd64` | SDK/Runtime build and test platform |
| `CI_LANGUAGE_PROFILES` | `all c cpp java csharp python` | Runtime profiles to build and test |
| `RUN_RUNTIME_EXAMPLES` | `true` | Run licensed DDS tests and Admin Console integration when UI Tools is enabled; requires `RTI_LICENSE_FILE_HOST` |
| `RTI_LICENSE_FILE_HOST` | not set | External readable RTI license; required by default |
| `RUN_UI_TOOLS` | `true` on amd64; `false` on arm64 | Build and test UI Tools |
| `RUN_LANGUAGE_MATRIX` | `true` | Build and test SDK/Runtime images |
| `RUN_DOCKERFILE_CHECKS` | `true` | Run Bake configuration checks |
| `NO_CACHE` | `false` | Rebuild without Docker layer cache |
| `KEEP_CI_IMAGES` | `false` | Keep locally built CI images |
| `MAX_RUNTIME_IMAGE_SIZE_MB` | `0` | Optional Runtime size limit; `0` disables it |
| `IMAGE_TAG_PREFIX` | `local` | Prefix for local image tags |
| `IMAGE_TAG_SUFFIX` | generated timestamp | Suffix for image tags and report directories |
| `PYTHON_TEST_BIN` | auto-created `.ci-venv` | Python interpreter with pytest and pexpect |

Reports are stored in `reports/` and are not committed. Jenkins uses the same
scripts and archives logs and JUnit XML. Its license credential is configured as
described in [the Jenkins setup](../resources/automation/README.md).

## Test resources

- [Test plan](TEST_PLAN.md): coverage, platform support, evidence, and known
  gaps.
- [Test dependencies](requirements-test.txt): pinned Python packages used by CI.
- [Pytest configuration](pytest.ini): shared test collection and JUnit settings.
- [Pub/sub test](pubsub_test.py): validates DDS communication in Runtime images.
- [UI Tools test](ui_tools_test.py): validates XRDP and Admin Console.

Jenkins runs the same entry point through
[resources/automation](../resources/automation/README.md).
