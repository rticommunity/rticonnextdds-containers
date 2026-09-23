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

## License

The _RTI Connext®_ UI Tools Dockerfile is licensed under the following
supplemental license terms and the repository `LICENSE`. RTI Connext software
included in the generated image remains subject to the applicable
[RTI License Agreements and Terms of Use](https://www.rti.com/get-connext/terms).

The generated image uses `hectorm/xubuntu`, which is based on
[Ubuntu](https://hub.docker.com/_/ubuntu), and content from
`rticom/connext-base`. It may install desktop packages and other third-party
components. Use of those components is subject to their applicable license
terms.

Additional information about third-party software included with RTI Connext is
available in the
[RTI documentation](https://community.rti.com/documentation#doc_third_party).

The RTI license agreement PDF is included in the generated image and can be
extracted with:

```sh
docker create --name connext-ui-tools-license local/connext-ui-tools:7.7.0
docker cp connext-ui-tools-license:/opt/rti.com/rti_connext_dds-7.7.0/RTI_License_Agreement_LM.pdf .
docker rm connext-ui-tools-license
```

## How to get a license file

An RTI license file is required to use RTI Connext software in the generated
image.

### Existing customers

If you are an RTI customer and need an RTI Connext license file, contact
[RTI support](https://www.rti.com/support).

### Evaluators

If you are not an RTI customer, request an [RTI Connext free
trial](https://www.rti.com/free-trial/connext) for release 7.7.0 or later.

### RTI Supplemental License

This RTI Supplemental License ("Supplemental License") applies only to the
Dockerfile provided with this README. It supplements, and does not replace, the
[repository `LICENSE`](https://github.com/rticommunity/rticonnextdds-containers/blob/main/LICENSE),
which governs use, modification and distribution of the Dockerfile.

This Supplemental License does not grant any rights to RTI Connext software. A
container image built from the Dockerfile (the "Generated Image") is built,
configured and maintained by you. RTI does not distribute or license the
Generated Image as a whole.

Any RTI Connext software contained in the Generated Image remains subject to
the RTI license agreement under which you obtained that software (the
"Applicable RTI License Agreement"). Building the Generated Image does not
grant any additional rights to use or distribute RTI Connext software.

Third-party software included in or installed while building the Generated
Image remains subject to its applicable license terms. You are responsible for
reviewing and complying with those terms.

The Dockerfile is provided under the warranty, support and liability terms in
the repository `LICENSE`. RTI is not responsible for the configuration or
maintenance of the Generated Image. Nothing in this Supplemental License
modifies the terms that apply to RTI Connext software under the Applicable RTI
License Agreement.
