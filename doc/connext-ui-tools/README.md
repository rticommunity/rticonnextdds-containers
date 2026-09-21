# Connext UI Tools

Use the public [Dockerfile](../../docker/connext-ui-tools/Dockerfile) from the
repository root. See [build configuration](../building.md).

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

The default tag is `local/connext-ui-tools:7.7.0`. This image is substantially
larger than Runtime because it includes a desktop environment.

## Connect

Get a license from the [RTI website](https://evaluation.rti.com/).
Use an existing user-defined Docker network containing the applications you
want to inspect. Admin Console must use their DDS domain and compatible
discovery/security configuration; sharing the network alone is not sufficient.

Create a password file outside the repository with a unique, non-empty,
single-line password.

```sh
export RTI_LICENSE_FILE_HOST=/absolute/path/rti_license.dat
export UI_PASSWORD_FILE_HOST=/absolute/path/ui-password.txt
export CONNEXT_DOCKER_NETWORK=my-application-network
docker compose -f docker/connext-ui-tools/compose.yaml up -d
```

Connect an RDP client to `localhost:3389`, select an Xorg session if prompted,
and log in as `user` with your password. Admin Console starts with the desktop.
Other tools are available from the desktop and under
`/opt/rti.com/rti_connext_dds-7.7.0/bin`.

The supplied Compose binds RDP to loopback and preserves preferences in the
`ui-home` volume. Stop it with the same Compose command using `down`; add
`--volumes` only when you intend to delete saved preferences.

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
`RUN_RUNTIME_EXAMPLES=true`, they also open Admin Console through an RDP session
and verify the resulting desktop. Logs and JUnit XML are written to
`reports/<run-id>/ui-tools/`.

## References

- [RTI Admin Console in Docker](https://www.rti.com/blog/rti-admin-console-in-docker)
- [Original tools Dockerfile](https://github.com/rajive/dockerfiles/blob/main/connext-tools/Dockerfile)
- [Desktop base and configuration](https://github.com/hectorm/docker-xubuntu)

## License and third-party components

These Dockerfiles are provided for users to build the images themselves. During
the build, the Dockerfiles may retrieve operating-system packages, desktop
components and other third-party software from upstream repositories and base
images maintained by their respective providers, including Ubuntu. RTI does not
host or directly provide those third-party components
through this repository. Their availability and use are subject to the
applicable provider terms and licenses, which the user is responsible for
reviewing and accepting.

RTI Connext software and RTI materials remain subject to the applicable RTI
license agreement. A valid RTI Connext license is required to use the image.
This notice does not grant any additional rights to RTI software or
third-party components.
