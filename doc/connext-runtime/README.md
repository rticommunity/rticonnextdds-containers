# Connext Runtime Image

Use the public [Dockerfile](../../docker/connext-runtime/Dockerfile) from the
repository root. See [build configuration](../building.md).
Run the commands below from the repository root.

The Runtime image is intended for running Connext applications. It extends the
public `rticom/connext-base:7.7.0` image and installs only the language runtime
dependencies required by an application.

Supported language profiles are:

```text
all
c
cpp
java
csharp
python
```

## Build

```sh
docker buildx bake --load runtime-all
```

Build a smaller C/C++ Runtime image:

```sh
docker buildx bake --load runtime-cpp
```

The resulting tags are `local/connext-runtime:7.7.0` and
`local/connext-cpp-runtime:7.7.0`. See [build configuration](../building.md)
for every Runtime profile and custom combinations.

This README is included in the image and can be extracted with `docker cp`:

```sh
docker create --name connext-runtime-readme local/connext-runtime:7.7.0
docker cp connext-runtime-readme:/opt/rti.com/rti_connext_dds-7.7.0/README.md ./README.md
docker rm connext-runtime-readme
```

## Quick start

Get an RTI Connext license from the [RTI website](https://evaluation.rti.com/).
Start the image directly with Docker:

```sh
export RTI_LICENSE_FILE_HOST=</absolute/path/rti_license.dat>
docker run --rm -it \
  --volume "${RTI_LICENSE_FILE_HOST}:/opt/rti.com/rti_connext_dds-7.7.0/rti_license.dat:ro" \
  local/connext-runtime:7.7.0
```

The license is mounted at runtime; it is not copied into the image. Add
application packages in a derived Dockerfile if needed. The Runtime image does
not contain headers, documentation, static libraries or SDK build tools.

## License

The _RTI Connext®_ Runtime Dockerfile is licensed under the following
supplemental license terms and the repository `LICENSE`. RTI Connext software
included in the generated image remains subject to the applicable
[RTI License Agreements and Terms of Use](https://www.rti.com/get-connext/terms).

The generated image uses [Ubuntu](https://hub.docker.com/_/ubuntu) and content
from [`rticom/connext-base`](https://hub.docker.com/r/rticom/connext-base). It
may install language runtimes and other third-party components, including
components provided by Microsoft. Use of those components is subject to their
applicable license terms.

The license terms supplied with `rticom/connext-base` are preserved in the
generated image at
`/opt/rti.com/rti_connext_dds-7.7.0/RTI_CONNEXT_BASE_README.md`.

Additional information about third-party software included with RTI Connext is
available in the
[RTI documentation](https://community.rti.com/documentation#doc_third_party).

The RTI license agreement PDF is included in the generated image and can be
extracted with:

```sh
docker create --name connext-runtime-license local/connext-runtime:7.7.0
docker cp connext-runtime-license:/opt/rti.com/rti_connext_dds-7.7.0/RTI_License_Agreement_LM.pdf .
docker rm connext-runtime-license
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
