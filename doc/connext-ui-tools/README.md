# Connext UI Tools

**Availability:** public [Dockerfile](../../docker/connext-ui-tools/Dockerfile),
no prebuilt image provided here. Run commands from the repository root.
See [build configuration](../building.md).

The image copies the RTI Connext 7.7.0 UI tools from the public
`rticom/connext-base:7.7.0` image: Admin Console, Launcher, Monitor, Shapes
Demo, System Designer and CLI tools. The image includes an Xfce desktop and
XRDP, separate from SDK and Runtime. It is not a slim runtime image.
Only Linux amd64 is supported by this target. Other host architectures require
Docker platform emulation.

## Build

```sh
docker buildx bake --load ui-tools
```

The default tag is `local/connext-ui-tools:7.7.0`. The desktop base is
`hectorm/xubuntu`, pinned by digest in the Dockerfile. Update the digest
deliberately and rerun the graphical test. This image is substantially larger
than Runtime; the Runtime size budget does not apply.

## Connect

Get a license from the [RTI website](https://evaluation.rti.com/).
Use an existing user-defined Docker network containing the applications you
want to inspect. Admin Console must use their DDS domain and compatible
discovery/security configuration; sharing the network alone is not sufficient.

Create a password file outside the repository with a unique, non-empty,
single-line password. Do not put passwords in Docker build arguments or images.
The image refuses to start without this file, or with the base's default password.

```sh
export RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat
export UI_PASSWORD_FILE_HOST=/absolute/path/ui-password.txt
export CONNEXT_DOCKER_NETWORK=my-application-network
docker compose -f docker/connext-ui-tools/compose.yaml up -d
```

Connect an RDP client to `localhost:3389`, select an Xorg session if prompted,
and log in as `user` with your password. Admin Console starts with the desktop.
On first launch, choose automatic discovery or manual domain selection in the
initial dialog. This choice is saved in the home volume.
Other installed tools are available through their launchers under
`/opt/rti.com/rti_connext_dds-7.7.0/bin`. The `admin-console` command also starts
Admin Console from a desktop terminal.

### Desktop startup behavior

Admin Console is the default application started by the Xfce session. The image
installs `/etc/xdg/autostart/admin-console.desktop`, which launches
`/usr/local/bin/admin-console` when the desktop session starts. This is a
convenience default, not a restriction on the desktop or the other installed
tools.

To disable the default launcher in a derived image, remove the system desktop
entry or add a user-level entry with the same filename and `Hidden=true`. To
start another tool automatically, replace the entry with a desktop file whose
`Exec` value points to the desired launcher. The other tools remain available
from the desktop applications menu and their launchers under the Connext
installation directory.

The supplied Compose publishes only RDP, bound to loopback. For remote access,
use an SSH tunnel to the Docker host rather than exposing RDP publicly.
XRDP generates a self-signed certificate; verify its fingerprint in the
container logs before trusting it. SSH from the desktop base is not published.
The base starts its supervisor as root; the graphical session runs as `user`.
This is a development/diagnostic desktop, not a hardened multi-tenant service.

Preferences persist in the `ui-home` volume. The license and password are
read-only mounts. Compose secrets here are file mounts, not an encrypted
secret store. The Docker host must be trusted and able to read these files.
`UI_RDP_PORT` changes the local port; `IMAGE_TAG_PREFIX` and `CONNEXT_VERSION`
select the image. Stop with the same Compose command using `down` instead of
`up -d`; add `--volumes` only when you intend to delete saved preferences.

The README is included in the image and can be extracted with `docker cp`:

```sh
docker create --name connext-ui-tools-readme local/connext-ui-tools:7.7.0
docker cp connext-ui-tools-readme:/opt/rti.com/rti_connext_dds-7.7.0/README.md ./README.md
docker rm connext-ui-tools-readme
```

## Validation

The same runner is used locally and by Jenkins:

```sh
RUN_LANGUAGE_MATRIX=false ./resources/automation/ci/ci-run.sh
RUN_LANGUAGE_MATRIX=false RUN_RUNTIME_EXAMPLES=true \
RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat ./resources/automation/ci/ci-run.sh
```

Without a license, tests check password enforcement and RDP readiness. With
`RUN_RUNTIME_EXAMPLES=true`, they additionally bootstrap an unprivileged XRDP
session and check that Admin Console opens a window. Logs and JUnit XML are
written to `reports/<run-id>/ui-tools/`. The licensed test also authenticates
from a FreeRDP client container and checks the received UI using screenshot
pixels and OCR. It does not test every installed tool or DDS discovery in the GUI.

Before release, manually connect through RDP, select the HelloWorld domain,
verify discovery and subscribed data, and reopen the desktop to check saved
preferences. No GPU passthrough or host networking is required by this setup.

## References

- [RTI Admin Console in Docker](https://www.rti.com/blog/rti-admin-console-in-docker)
- [Original tools Dockerfile](https://github.com/rajive/dockerfiles/blob/main/connext-tools/Dockerfile)
- [Desktop base and configuration](https://github.com/hectorm/docker-xubuntu)

## License and third-party components

These Dockerfiles are provided for users to build the images themselves. During
the build, the Dockerfiles may retrieve operating-system packages, desktop
components and other third-party software from upstream repositories and base
images maintained by their respective providers, including Ubuntu and
Microsoft. RTI does not host or directly provide those third-party components
through this repository. Their availability and use are subject to the
applicable provider terms and licenses, which the user is responsible for
reviewing and accepting.

RTI Connext software and RTI materials remain subject to the applicable RTI
license agreement. A valid RTI Connext license is required to use the image.
This notice does not grant any additional rights to RTI software or
third-party components.
