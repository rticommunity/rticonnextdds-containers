# Connext SDK Image

The SDK image is intended for building and debugging Connext applications.

**Availability:** public [Dockerfile](../../docker/connext-sdk/Dockerfile), no
prebuilt image provided here. Run the commands below from the repository root.
See [build configuration and platforms](../building.md).

It extends the public `rticom/connext-base:7.7.0` image with all supported
language build dependencies.

Language build dependencies are installed by `resources/scripts/install-language-dependencies.sh`.
The SDK always installs all supported languages:

```text
c
cpp
java
csharp
python
```

Build (all supported languages):

```sh
docker buildx bake --load sdk
```


Run:

```sh
docker run --rm -it \
  --volume "/absolute/path/rti_license.dat:/opt/rti.com/rti_connext_dds-7.7.0/rti_license.dat:ro" \
  local/connext-sdk:7.7.0
```

The README is included in the image and can be extracted with `docker cp`:

```sh
docker create --name connext-sdk-readme local/connext-sdk:7.7.0
docker cp connext-sdk-readme:/opt/rti.com/rti_connext_dds-7.7.0/README.md ./README.md
docker rm connext-sdk-readme
```

## License and third-party components

These Dockerfiles are provided for users to build the images themselves. During
the build, the Dockerfiles may retrieve operating-system packages, language
runtimes and other third-party components from upstream repositories and base
images maintained by their respective providers, including Ubuntu and
Microsoft. RTI does not host or directly provide those third-party components
through this repository. Their availability and use are subject to the
applicable provider terms and licenses, which the user is responsible for
reviewing and accepting.

RTI Connext software and RTI materials remain subject to the applicable RTI
license agreement. A valid RTI Connext license is required to use the image.
This notice does not grant any additional rights to RTI software or
third-party components.
