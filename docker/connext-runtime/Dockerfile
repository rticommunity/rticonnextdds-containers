# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=rticom/connext-base:7.7.0
FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE} AS connext-base

ARG CONNEXT_VERSION=7.7.0
ENV NDDSHOME=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}

USER root

COPY --chmod=0755 resources/scripts/prune-connext.sh /usr/local/sbin/prune-connext
RUN prune-connext runtime

FROM --platform=${TARGETPLATFORM} ubuntu:24.04

ARG CONNEXT_VERSION=7.7.0
ARG CONNEXT_LANGUAGES=all
ARG PREFIX=/opt/rti.com
ARG DOTNET_VERSION=10.0
ARG RTI_CONNEXT_PYTHON_PACKAGE_VERSION
ARG RTI_LICENSE_AGREEMENT_ACCEPTED=accepted

ENV CONNEXT_VERSION=${CONNEXT_VERSION} \
    CONNEXT_LANGUAGES=${CONNEXT_LANGUAGES} \
    PREFIX=${PREFIX} \
    DOTNET_VERSION=${DOTNET_VERSION} \
    RTI_CONNEXT_PYTHON_PACKAGE_VERSION=${RTI_CONNEXT_PYTHON_PACKAGE_VERSION} \
    NDDSHOME=${PREFIX}/rti_connext_dds-${CONNEXT_VERSION} \
    CONNEXTDDS_DIR=${PREFIX}/rti_connext_dds-${CONNEXT_VERSION} \
    RTI_LICENSE_FILE=${PREFIX}/rti_connext_dds-${CONNEXT_VERSION}/rti_license.dat \
    RTI_LICENSE_AGREEMENT_ACCEPTED=${RTI_LICENSE_AGREEMENT_ACCEPTED}

COPY --from=connext-base /opt/rti.com/.env /opt/rti.com/.env
COPY --from=connext-base /opt/rti.com/rti_connext_dds-${CONNEXT_VERSION} /opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}
COPY resources/scripts/install-language-dependencies.sh /usr/local/sbin/install-language-dependencies
COPY resources/scripts/language-utils.sh /usr/local/sbin/language-utils.sh

RUN chmod +x /usr/local/sbin/install-language-dependencies \
    && install-language-dependencies runtime "${CONNEXT_LANGUAGES}" \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1010 rtigroup \
    && useradd --uid 1010 --gid 1010 --create-home --shell /bin/bash rtiuser \
    && mkdir -p /home/rtiuser/rti_workspace \
    && chown -R rtiuser:rtigroup /home/rtiuser /opt/rti.com

COPY --chmod=0755 resources/scripts/rtientrypoint /usr/local/bin/rtientrypoint

USER rtiuser
WORKDIR /home/rtiuser/rti_workspace

SHELL ["/bin/bash", "-lc"]
ENV VIRTUAL_ENV=${PREFIX}/python-venv
ENV PATH="${VIRTUAL_ENV}/bin:${NDDSHOME}/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/rtientrypoint"]
CMD ["bash"]
