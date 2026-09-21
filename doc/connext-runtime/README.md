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
