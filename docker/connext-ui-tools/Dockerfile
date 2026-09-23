# syntax=docker/dockerfile:1.7
# RTI Supplemental License:
# https://github.com/rticommunity/rticonnextdds-containers/blob/main/doc/connext-ui-tools/README.md#rti-supplemental-license

ARG UI_BASE_IMAGE=hectorm/xubuntu@sha256:635fe60c65aa35fc8330d886cc06754bda924f3c799754d90eb5e1d99e3319e9
ARG CONNEXT_BASE_IMAGE=rticom/connext-base:7.7.0

FROM --platform=linux/amd64 ${CONNEXT_BASE_IMAGE} AS connext-base

ARG CONNEXT_VERSION=7.7.0
ENV NDDSHOME=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}

USER root
COPY --chmod=0755 resources/scripts/prune-connext.sh /usr/local/sbin/prune-connext
RUN cp "${NDDSHOME}/README.md" "${NDDSHOME}/RTI_CONNEXT_BASE_README.md" \
    && prune-connext ui-tools

FROM --platform=linux/amd64 ${UI_BASE_IMAGE}

ARG TARGETARCH
ARG CONNEXT_VERSION=7.7.0
ENV CONNEXT_VERSION=${CONNEXT_VERSION} \
    NDDSHOME=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION} \
    RTI_LICENSE_FILE=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}/rti_license.dat

USER root
COPY --from=connext-base /opt/rti.com/rti_connext_dds-${CONNEXT_VERSION} /opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}
COPY resources/scripts/rtientrypoint /usr/local/bin/rtientrypoint
COPY --chmod=0755 docker/connext-ui-tools/entrypoint.sh /usr/local/bin/ui-tools-entrypoint
COPY --chmod=0755 docker/connext-ui-tools/admin-console.sh /usr/local/bin/admin-console
COPY docker/connext-ui-tools/admin-console.desktop /etc/xdg/autostart/admin-console.desktop
COPY doc/connext-ui-tools/README.md /opt/rti.com/rti_connext_dds-${CONNEXT_VERSION}/README.md
RUN test "${TARGETARCH}" = amd64 \
    && apt-get update \
    && apt-get install -y --no-install-recommends x11-utils \
    && rm -rf /var/lib/apt/lists/* \
    && install -m 0644 /etc/xdg/autostart/admin-console.desktop /usr/share/applications/connext-admin-console.desktop

# Keep the base init and service supervisor; GUI sessions use its unprivileged user.
ENTRYPOINT ["/usr/bin/catatonit", "--", "/usr/local/bin/ui-tools-entrypoint"]
