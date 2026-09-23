# syntax=docker/dockerfile:1.7
# RTI Supplemental License:
# https://github.com/rticommunity/rticonnextdds-containers/blob/main/doc/connext-sdk/README.md#rti-supplemental-license

ARG BASE_IMAGE=rticom/connext-base:7.7.0
FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}

ARG CONNEXT_VERSION=7.7.0
ARG DOTNET_VERSION=10.0
ARG RTI_CONNEXT_PYTHON_PACKAGE_VERSION

ENV CONNEXT_VERSION=${CONNEXT_VERSION} \
    DOTNET_VERSION=${DOTNET_VERSION} \
    RTI_CONNEXT_PYTHON_PACKAGE_VERSION=${RTI_CONNEXT_PYTHON_PACKAGE_VERSION} \
    NDDSHOME=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION} \
    CONNEXTDDS_DIR=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION} \
    RTI_LICENSE_FILE=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}/rti_license.dat

USER root

RUN cp "${NDDSHOME}/README.md" "${NDDSHOME}/RTI_CONNEXT_BASE_README.md"

COPY resources/scripts/install-language-dependencies.sh /usr/local/sbin/install-language-dependencies
COPY resources/scripts/language-utils.sh /usr/local/sbin/language-utils.sh
COPY doc/connext-sdk/README.md /opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}/README.md

RUN chmod +x /usr/local/sbin/install-language-dependencies \
    && install-language-dependencies sdk all \
    && (getent group rtigroup >/dev/null || groupadd --gid 1010 rtigroup) \
    && (id -u rtiuser >/dev/null 2>&1 || useradd --uid 1010 --gid 1010 --create-home --shell /bin/bash rtiuser) \
    && mkdir -p "/home/rtiuser/rti_workspace/${CONNEXT_VERSION}" \
    && chown -R rtiuser:rtigroup /home/rtiuser /opt/rti.com

COPY --chmod=0755 resources/scripts/rtientrypoint /usr/local/bin/rtientrypoint

USER rtiuser
WORKDIR /home/rtiuser/rti_workspace/${CONNEXT_VERSION}

SHELL ["/bin/bash", "-lc"]
ENV VIRTUAL_ENV=/opt/rti.com/python-venv
ENV PATH="${VIRTUAL_ENV}/bin:${NDDSHOME}/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/rtientrypoint"]
CMD ["bash"]
