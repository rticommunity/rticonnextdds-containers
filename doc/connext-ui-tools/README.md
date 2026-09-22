# Connext UI Tools

Use the public [Dockerfile](../../docker/connext-ui-tools/Dockerfile) from the
repository root. See [build configuration](../building.md).
Run the commands below from the repository root.

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

This README is included in the image and can be extracted with `docker cp`:

```sh
docker create --name connext-ui-tools-readme local/connext-ui-tools:7.7.0
docker cp connext-ui-tools-readme:/opt/rti.com/rti_connext_dds-7.7.0/README.md ./README.md
docker rm connext-ui-tools-readme
```

## Quick start

Get an RTI Connext license from the [RTI website](https://evaluation.rti.com/).

Create a password file in the current directory with a unique, non-empty,
eight-character password. For example:

```sh
export UI_PASSWORD_FILE_HOST=./password.txt
umask 077
openssl rand -hex 4 | tr -d '\n' > "${UI_PASSWORD_FILE_HOST}"
```

Start it directly with Docker:

```sh
export RTI_LICENSE_FILE_HOST=</absolute/path/rti_license.dat>
docker run -d \
  --name connext-ui-tools \
  --platform linux/amd64 \
  --network host \
  --shm-size 1g \
  --env UI_PASSWORD_FILE=/run/secrets/ui_password \
  --mount type=bind,src="$PWD/password.txt",dst=/run/secrets/ui_password,readonly \
  --mount type=bind,src="${RTI_LICENSE_FILE_HOST}",dst=/opt/rti.com/rti_connext_dds-7.7.0/rti_license.dat,readonly \
  --mount type=volume,src=ui-home,dst=/home/user \
  local/connext-ui-tools:7.7.0
```

Once started, follow the [RDP connection](#rdp-connection) instructions.

Stop the direct container with:

```sh
docker rm -f connext-ui-tools
```

## Compose deployment

The supplied Compose uses the same host network and preserves preferences in
the `ui-home` volume. Create `password.txt` as described in [Quick start](#quick-start),
then start it with:

```sh
export UI_PASSWORD_FILE_HOST=./password.txt
export RTI_LICENSE_FILE_HOST=</absolute/path/rti_license.dat>
docker compose --project-directory . -f docker/connext-ui-tools/compose.yaml up -d
```

Once started, follow the [RDP connection](#rdp-connection) instructions.

Stop the Compose deployment with:

```sh
docker compose --project-directory . -f docker/connext-ui-tools/compose.yaml down
```

Add `--volumes` only when you intend to delete saved preferences.

## RDP connection

Connect an RDP client to `localhost:3389`, select an Xorg session if prompted,
and log in as `user` with your password. Admin Console starts with the desktop.
Other tools are available from the desktop and under
`/opt/rti.com/rti_connext_dds-7.7.0/bin`.

> **Docker Desktop:** Host networking is opt-in. On macOS, and on Windows when
> using Linux containers, enable **Enable host networking** under **Settings →
> Resources → Network** and restart Docker Desktop before starting the
> container or Compose deployment. Without it, `localhost:3389` on the host may
> not reach XRDP. Host networking is not supported when Docker Desktop is using
> Windows containers.
> See the [Docker host network documentation](https://docs.docker.com/engine/network/drivers/host/).

## References

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
license agreement. A valid RTI Connext license is required to use the generated
image. This notice does not grant any additional rights to RTI software or
third-party components.
