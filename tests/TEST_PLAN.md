# Test Plan

**Project:** RTI Connext Containers
**Validated version:** 7.7.0
**Validated platforms:** `linux/amd64` and `linux/arm64` for SDK/Runtime; UI Tools on `linux/amd64`
**Scope:** functional build, runtime, UI and CI checks

## 1. Objective

Validate that the Docker images for SDK, Runtime and UI Tools:

- build with the expected configuration;
- contain the dependencies required for each language;
- compile Connext DDS applications generated from the test IDL;
- support real pub/sub communication between containers;
- expose a working XRDP session for UI Tools;
- open Admin Console correctly when a license is provided;
- generate traceable logs, screenshots and JUnit results;
- do not depend on a license embedded in the repository or images.

The plan prioritizes real behavior over superficial checks such as file or process existence.

## 2. CI entry point

The single entry point is [resources/automation/ci/ci-run.sh](../resources/automation/ci/ci-run.sh). It performs:

1. script and source checks;
2. Dockerfile static validation with Bake;
3. language matrix build and validation;
4. UI Tools and XRDP validation;
5. artifact and JUnit generation.

The full licensed run is:

```sh
RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat \
RUN_RUNTIME_EXAMPLES=true \
./resources/automation/ci/ci-run.sh
```

The license must exist only on the host or CI agent and is mounted read-only. It is never part of the Docker build context or repository.

## 3. Platform compatibility

### 3.1 Supported platform matrix

| Image family | `linux/amd64` | `linux/arm64` |
| --- | --- | --- |
| SDK | Supported and validated | Supported and validated |
| Runtime | Supported and validated | Supported and validated |
| UI Tools | Supported and validated | Not supported by the current Dockerfile |
| RDP test client | Supported and validated | Not supported by the current UI Tools flow |

The default platform is `linux/amd64`. Platform selection is controlled by
Docker and is independent of the host operating system. UI Tools and its RDP
test client are always built for amd64 because the UI Tools Dockerfile requires
the amd64 Connext tools package. The `DOCKER_PLATFORM` variable applies to SDK
and Runtime targets.

### 3.2 Tested platform coverage

The test suite validates SDK and Runtime images for both `linux/amd64` and
`linux/arm64`. The same language matrix and Runtime variants are tested on
both platforms, including real publisher/subscriber communication.

The platform matrix includes the complete amd64 and arm64 validation flows.
Platform-specific build and CI commands are documented in the
[Testing and CI](README.md#platforms).

UI Tools and the RDP test client are tested only on `linux/amd64`, because the
current UI Tools Dockerfile requires the amd64 Connext tools package. This is
an intentional product limitation rather than an untested SDK or Runtime
platform.

## 4. Executed coverage matrix

### 4.1 Repository and script checks

Implemented in [resources/automation/ci/ci-check.sh](../resources/automation/ci/ci-check.sh):

| Area | Coverage |
| --- | --- |
| Bash syntax | Runs `bash -n` automatically on every `*.sh` file in the repository |
| Python syntax | Runs `py_compile` automatically on every `*.py` file in the repository |
| Language utilities | Rejects invalid profiles and empty selections |

### 4.2 Docker and Bake configuration

The following command is executed:

```sh
docker buildx bake --check all ui-test
```

It resolves and checks these targets:

- `sdk`;
- `runtime-all`;
- `runtime-c`;
- `runtime-cpp`;
- `runtime-java`;
- `runtime-csharp`;
- `runtime-python`;
- `ui-tools`;
- `rdp-test-client`.

This validates HCL configuration, contexts, Dockerfiles, arguments and declared dependencies before a real build starts.

### 4.3 Example build and compilation

The matrix compiles the HelloWorld example from [resources/idls/HelloWorld.idl](../resources/idls/HelloWorld.idl) using the SDK image.

Covered languages:

- C;
- C++98;
- C++11;
- Java;
- C#;
- Python.

Compilation confirms that the SDK image contains the compiler, code generator and development dependencies required for each language.

### 4.4 Runtime pub/sub tests

The main test is [pubsub_test.py](pubsub_test.py). Each profile creates:

- an isolated Docker network;
- a subscriber container;
- a publisher container;
- separate logs for both processes;
- a QoS configuration file;
- explicit cleanup of containers and network.

The test waits for the subscriber to receive a `HelloWorld` sample. Process startup or an open port alone is not considered success.

The Runtime matrix contains one complete test covering all profiles and one
language-specific test for each profile:

| Group | Profiles |
| --- | --- |
| Complete Runtime | C, C++98, C++11, Java, C#, Python |
| C Runtime | C |
| C++98 Runtime | C++98 |
| C++11 Runtime | C++11 |
| Java Runtime | Java |
| C# Runtime | C# |
| Python Runtime | Python |

This covers real communication between applications compiled with the SDK and executed with Runtime. It also indirectly validates shared libraries, entrypoints, language dependencies, license usage and QoS configuration.

### 4.5 UI Tools, XRDP and Admin Console

The test is [ui_tools_test.py](ui_tools_test.py) and covers two
component-level validation paths.

#### RDP service test

This path validates the container startup contract and the RDP service itself:

- Runs the image without a configured password and confirms that startup is
  rejected.
- Verifies that the rejection message requires `UI_PASSWORD_FILE`.
- Starts the image with a temporary password.
- Confirms that XRDP accepts connections on port `3389`.
- Does not validate the Admin Console application or its UI.

#### Admin Console test

This path validates the Admin Console application through an RDP session:

1. Generates a temporary password and mounts it as a read-only secret.
2. Mounts the RTI license as a read-only file and starts the Admin Console
    container.
3. Relies on the documented desktop default: Admin Console is launched by the
  Xfce session through `/etc/xdg/autostart/admin-console.desktop`.
4. Publishes the XRDP port on loopback and confirms that port `3389` accepts
     connections.
5. Waits for a visible Admin Console window, not only the Java splash screen.
6. Starts a second container based on [rdp-test-client.Dockerfile](connext-rdp-test-client/rdp-test-client.Dockerfile).
7. Shares the Admin Console container network with `--network container:<name>`.
8. Starts `Xvfb` and `openbox` in the client.
9. Opens a `1280x800` FreeRDP window inside a `1600x1000` virtual desktop.
10. Captures the client desktop, not the internal Admin Console X11 display.
11. Confirms that the capture is neither empty nor completely black.
12. Runs Tesseract OCR against an enlarged version of the image.
13. Requires the expected UI elements:
    - `Administration Console`;
    - `Auto-join`;
    - `active domains`.
14. Archives the screenshot, window tree, RDP client log, session log and
        container log.

This test simultaneously demonstrates that XRDP accepts connections, FreeRDP can authenticate from another container, and the received remote UI contains the expected functional interface.

## 5. Artifacts and traceability

Each run creates a `reports/<run-id>/` directory containing, as applicable:

- resolved Bake configuration;
- build metadata;
- image inspection data;
- publisher and subscriber logs;
- UI container logs;
- X11 session errors;
- Admin Console window tree;
- FreeRDP client log;
- `desktop.png` screenshot;
- per-language and UI Tools JUnit XML.

Jenkins archives `reports/**/*` and publishes the XML files through the JUnit publisher. A build or test failure fails the job.

## 9. Conclusion

The current suite covers practically all core functional behavior in the repository: build, compilation, multi-language DDS execution, external licensing, basic startup security, XRDP, RDP connection from an independent container, remote capture, expected UI content and CI reporting.

It does not cover image security, prolonged resilience or performance.
