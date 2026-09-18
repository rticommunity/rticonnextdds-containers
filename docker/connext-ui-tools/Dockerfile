# syntax=docker/dockerfile:1.7
ARG UI_BASE_IMAGE=hectorm/xubuntu@sha256:635fe60c65aa35fc8330d886cc06754bda924f3c799754d90eb5e1d99e3319e9
FROM ${UI_BASE_IMAGE}

ARG TARGETARCH
ARG CONNEXT_VERSION=7.7.0
ARG CONNEXT_INSTALL_METHOD=apt
ENV CONNEXT_VERSION=${CONNEXT_VERSION} \
    CONNEXT_INSTALL_METHOD=${CONNEXT_INSTALL_METHOD} \
    NDDSHOME=/opt/rti.com/rti_connext_dds-${CONNEXT_VERSION} \
    RTI_LICENSE_FILE=/licenses/rti_license.dat

USER root
COPY --chmod=0755 resources/scripts/install-connext.sh /usr/local/sbin/install-connext
COPY --chmod=0755 docker/connext-ui-tools/entrypoint.sh /usr/local/bin/ui-tools-entrypoint
COPY --chmod=0755 docker/connext-ui-tools/admin-console.sh /usr/local/bin/admin-console
COPY docker/connext-ui-tools/admin-console.desktop /etc/xdg/autostart/admin-console.desktop
RUN test "${TARGETARCH}" = amd64 \
    && install-connext ui-tools \
    && apt-get update \
    && apt-get install -y --no-install-recommends x11-utils \
    && rm -rf /var/lib/apt/lists/* \
    && install -m 0644 /etc/xdg/autostart/admin-console.desktop /usr/share/applications/connext-admin-console.desktop

# Keep the base init and service supervisor; GUI sessions use its unprivileged user.
ENTRYPOINT ["/usr/bin/catatonit", "--", "/usr/local/bin/ui-tools-entrypoint"]
