# syntax=docker/dockerfile:1.7
FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        freerdp2-x11 \
        imagemagick \
        openbox \
        tesseract-ocr \
        x11-apps \
        x11-utils \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

COPY tests/connext-rdp-test-client/rdp-client-test.sh /usr/local/bin/rdp-client-test.sh
