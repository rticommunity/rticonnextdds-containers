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
