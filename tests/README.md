# Testing and CI

This directory contains the automated validation for the RTI Connext container
images.

## Run the checks

From the repository root:

```sh
./resources/automation/ci/ci-run.sh
```

This validates the repository, Bake configuration, image builds, and generated
examples. It does not run DDS applications without a license.

To run the Runtime and Admin Console integration tests, provide a readable RTI
license file outside the repository:

```sh
RUN_RUNTIME_EXAMPLES=true \
RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat \
./resources/automation/ci/ci-run.sh
```

## Platforms

The default SDK/Runtime matrix uses `linux/amd64`. For `linux/arm64`, run:

```sh
DOCKER_PLATFORM=linux/arm64 RUN_UI_TOOLS=false RUN_RUNTIME_EXAMPLES=true \
RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat \
./resources/automation/ci/ci-run.sh
```

UI Tools and its RDP client are amd64-only and are tested separately. Docker
needs emulation when the selected architecture differs from the host.

## CI Options

Tests require Bash and Python 3.9+ with venv/pip. The runner creates a local
environment with the pinned [test dependencies](requirements-test.txt).
The Docker daemon must see the bind-mount paths and its published loopback
ports must be reachable from the runner.

| Environment variable | Default | Purpose |
| --- | --- | --- |
| CI_LANGUAGE_PROFILES | all c cpp java csharp python | Runtime profiles |
| RUN_DOCKERFILE_CHECKS | true | Bake static checks |
| RUN_LANGUAGE_MATRIX | true | SDK/Runtime builds and examples |
| RUN_UI_TOOLS | true | UI Tools build and RDP checks |
| RUN_RUNTIME_EXAMPLES | false locally, true in Jenkins | Licensed DDS and graphical tests |
| RTI_LICENSE_FILE_HOST | empty locally | Absolute path to an external license |
| KEEP_CI_IMAGES | false | Retain temporary image tags |
| MAX_RUNTIME_IMAGE_SIZE_MB | 0 | Runtime size limit in MiB; zero disables |
| NO_CACHE | false | Rebuild without Docker layer cache |
| IMAGE_TAG_SUFFIX | generated timestamp | Override with a unique value for concurrent jobs |
| PYTHON_TEST_BIN | project venv | Interpreter with pytest and pexpect |

Only builds for the public Dockerfiles are tested; the prebuilt-only catalog
entries are not part of the build matrix. Reports are stored in `reports/` and
are not committed. Jenkins uses the same scripts, archives logs and JUnit XML,
and does not publish images. Its license credential is configured as described
in [the Jenkins setup](../resources/automation/README.md).

## Test resources

- [Test plan](TEST_PLAN.md): coverage, platform support, evidence, and known
  gaps.
- [Test dependencies](requirements-test.txt): pinned Python packages used by CI.
- [Pytest configuration](pytest.ini): shared test collection and JUnit settings.
- [Pub/sub test](pubsub_test.py): validates DDS communication in Runtime images.
- [UI Tools test](ui_tools_test.py): validates XRDP and Admin Console.

Jenkins runs the same entry point through
[resources/automation](../resources/automation/README.md).
