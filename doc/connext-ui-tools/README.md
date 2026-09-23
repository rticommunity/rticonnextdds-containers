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
[`rticom/connext-base`](https://hub.docker.com/r/rticom/connext-base). It may
install desktop packages and other third-party components. Use of those
components is subject to their applicable license terms.

The license terms supplied with `rticom/connext-base` are preserved in the
generated image at
`/opt/rti.com/rti_connext_dds-7.7.0/RTI_CONNEXT_BASE_README.md`.

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

A container image built from the Dockerfile (the "Generated Image") is built,
configured and maintained by you. This Supplemental License does not license
the Generated Image as a whole.

**RTI Connext Base Image and Software.** The Dockerfile uses
`rticom/connext-base`, whose license terms are preserved in the Generated
Image as described above. RTI Connext software remains subject to the license
agreement under which you obtained it (the "Applicable RTI License
Agreement"). Building the Generated Image does not grant additional rights to
use or distribute RTI Connext software.

**Use Rights.** The Dockerfile may be used only in connection with configuring,
building, testing and using RTI Connext software. You are responsible for any
modifications to the Dockerfile and for the configuration and operation of the
Generated Image.

**Disclaimer of Warranties.** The Dockerfile is provided on an "AS IS" basis
under the warranty terms in the repository `LICENSE`. RTI does not warrant any
Generated Image built or configured by you.

**Feedback.** Any suggestions or ideas you provide to RTI regarding the
Dockerfile (collectively, "Feedback"), may be used and exploited in any and
every way by RTI (including without limitation, by granting sublicenses), on a
non-exclusive, perpetual, irrevocable, transferable, and worldwide basis,
without any compensation, without any obligation to report on such use, and
without any other restriction or obligation to you.

**Limitation of Liability.** RTI's liability arising from the Dockerfile is
subject to the repository `LICENSE`. Nothing in this Supplemental License
modifies the terms that apply to RTI Connext software under the Applicable RTI
License Agreement.

**OSS.** The Dockerfile may retrieve third-party software from upstream
repositories. RTI does not host or distribute those components through this
repository. Each component remains subject to its applicable license terms.
Open-source software included in `rticom/connext-base` remains subject to the
notices supplied with that base image.

**General.** This Supplemental License applies only to the Dockerfile. It does
not modify the terms that apply to `rticom/connext-base`, RTI Connext software
or third-party components.
