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
from `rticom/connext-base`. It may install language runtimes and other
third-party components, including components provided by Microsoft. Use of
those components is subject to their applicable license terms.

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
