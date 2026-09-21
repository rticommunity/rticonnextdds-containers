# Connext Runtime Image

The Runtime image is intended for running Connext applications. It extends the
public `rticom/connext-base:7.7.0` image and installs only the language
runtime dependencies required by an application.

**Availability:** public [Dockerfile](../../docker/connext-runtime/Dockerfile),
no prebuilt images provided here. Run commands from the repository root.
See [all variant tags and build options](../building.md).

Language runtime dependencies are installed by
`resources/scripts/install-language-dependencies.sh`. Supported language profiles are:

```text
all
c
cpp
java
csharp
python
```

Build:

```sh
docker buildx build --load \
  --file docker/connext-runtime/Dockerfile \
  --tag local/connext-runtime:7.7.0 \
  .
```

Build a smaller C/C++ Runtime image:

```sh
docker buildx build --load \
  --file docker/connext-runtime/Dockerfile \
  --tag local/connext-cpp-runtime:7.7.0 \
  --build-arg CONNEXT_LANGUAGES=cpp \
  .
```

Run:

```sh
docker run --rm -it \
  --volume "/absolute/path/rti_license.dat:/opt/rti.com/rti_connext_dds-7.7.0/rti_license.dat:ro" \
  local/connext-runtime:7.7.0
```

The README is included in the image and can be extracted with `docker cp`:

```sh
docker create --name connext-runtime-readme local/connext-runtime:7.7.0
docker cp connext-runtime-readme:/opt/rti.com/rti_connext_dds-7.7.0/README.md ./README.md
docker rm connext-runtime-readme
```

The license is mounted at runtime; it is not copied into the image. Add
application packages in a derived Dockerfile if needed. The Runtime image does
not contain headers, documentation, static libraries or SDK build tools.

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
license agreement. A valid RTI Connext license is required to run applications
using the image. This notice does not grant any additional rights to RTI
software or third-party components.
