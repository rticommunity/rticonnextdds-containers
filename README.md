# RTI Connext Containers

Documentation for RTI-published container images and public Dockerfiles for
images that users build themselves. A documented image does not necessarily
have a public Dockerfile, and a public Dockerfile does not imply that RTI
distributes the resulting image.

## Catalog

Availability below applies to this `release/7.7.0` line. Registry links lead to
RTI's published images; `local/...` tags in build examples are local outputs,
not images to pull from Docker Hub. "Not provided" in the Dockerfile column
means that this repository does not contain the Dockerfile for that image.

| Image or family | Prebuilt image | Public Dockerfile | Documentation |
| --- | --- | --- | --- |
| cloud-discovery-service | [Docker Hub](https://hub.docker.com/r/rticom/cloud-discovery-service) | Not provided | [Usage](doc/cloud-discovery-service/README.md) |
| collector-service | [Docker Hub](https://hub.docker.com/r/rticom/collector-service) | Not provided | [Usage](doc/collector-service/README.md) |
| dds-ping | [Docker Hub](https://hub.docker.com/r/rticom/dds-ping) | Not provided | [Usage](doc/dds-ping/README.md) |
| dds-spy | [Docker Hub](https://hub.docker.com/r/rticom/dds-spy) | Not provided | [Usage](doc/dds-spy/README.md) |
| perftest | [Docker Hub](https://hub.docker.com/r/rticom/perftest) | Not provided | [Usage](doc/perftest/README.md) |
| persistence-service | [Docker Hub](https://hub.docker.com/r/rticom/persistence-service) | Not provided | [Usage](doc/persistence-service/README.md) |
| recording-service | [Docker Hub](https://hub.docker.com/r/rticom/recording-service) | Not provided | [Usage](doc/recording-service/README.md) |
| replay-service | [Docker Hub](https://hub.docker.com/r/rticom/replay-service) | Not provided | [Usage](doc/replay-service/README.md) |
| routing-service | [Docker Hub](https://hub.docker.com/r/rticom/routing-service) | Not provided | [Usage](doc/routing-service/README.md) |
| web-integration-service | [Docker Hub](https://hub.docker.com/r/rticom/web-integration-service) | Not provided | [Usage](doc/web-integration-service/README.md) |
| Connext SDK | Not provided; build locally | [Dockerfile](docker/connext-sdk/Dockerfile) | [Build and usage](doc/connext-sdk/README.md) |
| Connext Runtime and language variants | Not provided; build locally | [Dockerfile](docker/connext-runtime/Dockerfile) | [Build and usage](doc/connext-runtime/README.md) |
| Connext UI Tools | Not provided; build locally | [Dockerfile](docker/connext-ui-tools/Dockerfile) | [Build and RDP](doc/connext-ui-tools/README.md) |

## Build Locally

Install Docker with Buildx/Bake. Run commands from the repository root:

```sh
docker buildx bake --load                  # SDK and complete Runtime
docker buildx bake --load all              # SDK, Runtime variants and UI Tools
```

Bake only builds images with Dockerfiles in this repository. It does not build
or publish the other images in the catalog. See [build configuration](doc/building.md)
for tags, language selection, platforms and installation options.

For a publisher, two subscribers and Admin Console on one Docker network, see
the [HelloWorld Compose example](examples/hello_world/README.md). For local and
Jenkins validation, see [Testing and CI](tests/README.md).

## Versions and Licensing

The public Dockerfiles on this release line default to Connext `7.7.0`, using
the APT packages for `7.7.0.0`. [VERSION](VERSION) records that build baseline,
not the version of every image in the catalog. It is not read automatically by
Bake. Each published image's documentation and registry tags describe its own
available versions. A `latest` registry tag can move independently of this branch.

Existing release branches and Git tags retain version-specific documentation.
No older tag is changed by adding these Dockerfiles. The `doc/` paths remain
stable, including Collector Service's short and full README files.

Repository licensing is in [LICENSE](LICENSE). Connext and third-party packages
retain their own license terms. No RTI runtime license or installer is included.
Request a license through the [RTI evaluation website](https://evaluation.rti.com/)
and keep it outside the repository.
