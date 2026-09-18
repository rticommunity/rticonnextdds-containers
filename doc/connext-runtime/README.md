# Connext Runtime Image

The Runtime image is intended for running Connext applications. It installs a
smaller package set than the SDK image, and it can install only the language
runtime dependencies required by an application.

**Availability:** public [Dockerfile](../../docker/connext-runtime/Dockerfile),
no prebuilt images provided here. Run commands from the repository root.
See [all variant tags and build options](../building.md).

Default Connext packages:

```text
rti-connext-dds-7.7.0-lib
```

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

Add services or other Connext packages by overriding `CONNEXT_APT_PACKAGES`:

```sh
docker buildx build --load \
  --file docker/connext-runtime/Dockerfile \
  --tag local/connext-runtime:7.7.0-services \
  --build-arg 'CONNEXT_APT_PACKAGES=rti-connext-dds-7.7.0-lib rti-connext-dds-7.7.0-services-all' \
  .
```
