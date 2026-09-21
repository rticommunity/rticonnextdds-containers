# RTI Connext Container Images Documentation

Welcome to the official repository for [RTI Connext Container Images](https://hub.docker.com/u/rticom). This repository contains the documentation for all available container images provided by RTI and their respective tags.

## Overview

Each container image provided by RTI is designed to help you quickly and efficiently deploy and run your applications in a containerized environment.

### Documentation

You can find the documentation for a specific image and version by navigating to the appropriate directory under the `doc/` folder.

> **Note:** The documentation shown on DockerHub and in the `main` branch of this repository refers to the `latest` tag for each image, which corresponds to the most recent image released by RTI. For specific tag documentation, refer to the appropriate tag in this repository.

### Quick Links

- **DockerHub Repository**: [RTI Community on DockerHub](https://hub.docker.com/u/rticom)
- **RTI Connext Documentation**: [RTI Documentation Portal](https://community.rti.com/documentation)

## RTI-published images

The following images are distributed by RTI through Docker Hub. Their documentation
is maintained in this repository, but their Dockerfiles are not provided here.

| Image | Docker Hub | Documentation |
| --- | --- | --- |
| cloud-discovery-service | [Image](https://hub.docker.com/r/rticom/cloud-discovery-service) | [Usage](doc/cloud-discovery-service/README.md) |
| collector-service | [Image](https://hub.docker.com/r/rticom/collector-service) | [Usage](doc/collector-service/README.md) |
| dds-ping | [Image](https://hub.docker.com/r/rticom/dds-ping) | [Usage](doc/dds-ping/README.md) |
| dds-spy | [Image](https://hub.docker.com/r/rticom/dds-spy) | [Usage](doc/dds-spy/README.md) |
| perftest | [Image](https://hub.docker.com/r/rticom/perftest) | [Usage](doc/perftest/README.md) |
| persistence-service | [Image](https://hub.docker.com/r/rticom/persistence-service) | [Usage](doc/persistence-service/README.md) |
| recording-service | [Image](https://hub.docker.com/r/rticom/recording-service) | [Usage](doc/recording-service/README.md) |
| replay-service | [Image](https://hub.docker.com/r/rticom/replay-service) | [Usage](doc/replay-service/README.md) |
| routing-service | [Image](https://hub.docker.com/r/rticom/routing-service) | [Usage](doc/routing-service/README.md) |
| web-integration-service | [Image](https://hub.docker.com/r/rticom/web-integration-service) | [Usage](doc/web-integration-service/README.md) |

## Public Dockerfiles

This repository also provides Dockerfiles for SDK, Runtime and UI Tools images
that users can build on their own systems. These are separate from the Docker
Hub images listed above.

| Image | Docker Hub image | Dockerfile | Documentation |
| --- | --- | --- | --- |
| Connext SDK | Not provided; build locally | [Dockerfile](docker/connext-sdk/Dockerfile) | [Build and usage](doc/connext-sdk/README.md) |
| Connext Runtime and language variants | Not provided; build locally | [Dockerfile](docker/connext-runtime/Dockerfile) | [Build and usage](doc/connext-runtime/README.md) |
| Connext UI Tools | Not provided; build locally | [Dockerfile](docker/connext-ui-tools/Dockerfile) | [Build and RDP](doc/connext-ui-tools/README.md) |

Install Docker with Buildx/Bake and run these commands from the repository root:

```sh
docker buildx bake --load                  # SDK and complete Runtime
docker buildx bake --load all              # SDK, Runtime variants and UI Tools
```

Bake builds the Dockerfile targets in this repository. See [Build
configuration](doc/building.md) for tags, language selection and platforms.

For a publisher, two subscribers and Admin Console on one Docker network, see
the [HelloWorld Compose example](examples/hello_world/README.md). For local and
Jenkins validation, see [Testing and CI](tests/README.md).

## Licensing

Repository licensing is in [LICENSE](LICENSE). For a Connext license, visit the
[RTI website](https://evaluation.rti.com/).
