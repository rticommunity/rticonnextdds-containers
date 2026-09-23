# Test Plan

**Project:** RTI Connext Containers
**Platforms:** `linux/amd64` and `linux/arm64` for SDK/Runtime; UI Tools on `linux/amd64`
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

The single entry point is
[resources/automation/ci/ci-run.sh](../resources/automation/ci/ci-run.sh).
See [Testing and CI](README.md) for execution commands, license requirements,
options and platform behavior.

## 3. Platform compatibility

| Image family | `linux/amd64` | `linux/arm64` |
| --- | --- | --- |
| SDK | Supported | Supported |
| Runtime | Supported | Supported |
| UI Tools | Supported | Not supported |
| RDP test client | Supported | Not supported |

The default platform is `linux/amd64`; `DOCKER_PLATFORM` selects the SDK and
Runtime platform. The complete language matrix and Runtime variants are tested
on both supported platforms. UI Tools and the RDP test client are amd64-only
and are skipped automatically on ARM64. See [Testing and CI](README.md#platforms)
for platform-specific commands.

## 4. Executed coverage matrix

The following table summarizes the executed checks. Each entry links to the
detailed coverage below.

| Area | Summary | Details |
| --- | --- | --- |
| Repository and scripts (`ci-check.sh`) | Bash, Python and language-helper validation | [Repository and script checks](#41-repository-and-script-checks) |
| Docker and Bake (`docker buildx bake --check`) | Dockerfile, target, context and argument validation | [Docker and Bake configuration](#42-docker-and-bake-configuration) |
| SDK and examples (`test-connext-examples.sh`) | Multi-language HelloWorld generation and compilation | [Example build and compilation](#43-example-build-and-compilation) |
| Runtime communication (`pubsub_test.py`) | Real publisher/subscriber DDS communication | [Runtime pub/sub tests](#44-runtime-pubsub-tests) |
| UI and Admin Console (`ui_tools_test.py`) | XRDP, FreeRDP, desktop capture and Admin Console UI | [UI Tools, XRDP and Admin Console](#45-ui-tools-xrdp-and-admin-console) |

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
