# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=rticom/connext-base:7.7.0
FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}

ARG CONNEXT_VERSION=7.7.0
ARG PREFIX=/opt/rti.com
ARG DOTNET_VERSION=10.0
ARG RTI_CONNEXT_PYTHON_PACKAGE_VERSION
ARG IMAGE_USER=rtiuser
ARG IMAGE_GROUP=rtigroup
ARG IMAGE_UID=1010
ARG IMAGE_GID=1010
ARG RTI_LICENSE_AGREEMENT_ACCEPTED=accepted

ENV CONNEXT_VERSION=${CONNEXT_VERSION} \
    PREFIX=${PREFIX} \
    DOTNET_VERSION=${DOTNET_VERSION} \
    RTI_CONNEXT_PYTHON_PACKAGE_VERSION=${RTI_CONNEXT_PYTHON_PACKAGE_VERSION} \
    NDDSHOME=${PREFIX}/rti_connext_dds-${CONNEXT_VERSION} \
    CONNEXTDDS_DIR=${PREFIX}/rti_connext_dds-${CONNEXT_VERSION} \
    RTI_LICENSE_FILE=${PREFIX}/rti_connext_dds-${CONNEXT_VERSION}/rti_license.dat \
    RTI_LICENSE_AGREEMENT_ACCEPTED=${RTI_LICENSE_AGREEMENT_ACCEPTED}

COPY resources/scripts/install-language-dependencies.sh /usr/local/sbin/install-language-dependencies
COPY resources/scripts/language-utils.sh /usr/local/sbin/language-utils.sh
COPY resources/scripts/rtientrypoint /usr/local/bin/rtientrypoint

RUN chmod +x /usr/local/sbin/install-language-dependencies /usr/local/bin/rtientrypoint \
    && install-language-dependencies sdk all \
    && groupadd --gid "${IMAGE_GID}" "${IMAGE_GROUP}" \
    && useradd --uid "${IMAGE_UID}" --gid "${IMAGE_GID}" --create-home --shell /bin/bash "${IMAGE_USER}" \
    && mkdir -p "/home/${IMAGE_USER}/rti_workspace/${CONNEXT_VERSION}" \
    && chown -R "${IMAGE_USER}:${IMAGE_GROUP}" "/home/${IMAGE_USER}" "${PREFIX}"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        iputils-ping \
        net-tools \
    && rm -rf /var/lib/apt/lists/*

USER ${IMAGE_USER}
WORKDIR /home/${IMAGE_USER}/rti_workspace/${CONNEXT_VERSION}

SHELL ["/bin/bash", "-lc"]
ENV VIRTUAL_ENV=${PREFIX}/python-venv
ENV PATH="${VIRTUAL_ENV}/bin:${NDDSHOME}/bin:${PATH}"

ENTRYPOINT ["rtientrypoint"]
CMD ["bash"]
