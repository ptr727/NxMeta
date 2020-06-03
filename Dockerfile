# Use Ubuntu Bionic
FROM ubuntu:bionic

# Sign up for program participation at the developer portal:
# https://support.networkoptix.com/hc/en-us/articles/360046713714-Get-an-Nx-Meta-Build
# Beta versions are listed under the patches section:
# https://meta.nxvms.com/downloads/patches
ARG DOWNLOAD_URL="https://updates.networkoptix.com/metavms/30731/linux/metavms-server-4.1.0.30731-linux64-beta-prod.deb"
ARG DOWNLOAD_VERSION="4.1.0.30731 R5"

# Prevent EULA and confirmation prompts in installers
ENV DEBIAN_FRONTEND=noninteractive \
# NxWitness (networkoptix) or DWSpectrum (digitalwatchdog) or NxMeta (networkoptix-metavms)
    COMPANY_NAME="networkoptix-metavms"

LABEL name="NxMeta" \
    version=${DOWNLOAD_VERSION} \
    download=${DOWNLOAD_URL} \
    description="NxMeta VMS Docker" \
    maintainer="Pieter Viljoen <ptr727@users.noreply.github.com>"

# Install tools
RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        mc \
        nano \
        strace \
        wget \
    && apt-get clean \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/apt/lists/*

# Download the DEB installer file
RUN wget -nv -O ./vms_server.deb ${DOWNLOAD_URL}

# Install the mediaserver
# Add missing dependencies (gdb)
# Remove the root tool to prevent it from being used in service mode
RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        gdb \
        ./vms_server.deb \
    && apt-get clean \
    && apt-get autoremove --purge \
    && rm -rf /opt/${COMPANY_NAME}/mediaserver/bin/root-tool-bin \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf ./vms_server.deb

# Expose port 7001
EXPOSE 7001

# Create mount points
# Links will be created at runtime in the etc/cont-init.d/50-relocate-files script
# /opt/digitalwatchdog/mediaserver/etc -> /config/etc
# /opt/digitalwatchdog/mediaserver/var -> /config/var
# /opt/digitalwatchdog/mediaserver/var/data -> /media
# /config is for configuration
# /media is for media recording
# /archive is for media backups
VOLUME /config /media /archive
