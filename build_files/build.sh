#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

### Surface Linux Repository
dnf5 config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo
dnf5 config-manager setopt \
    "linux-surface.baseurl=https://pkg.surfacelinux.com/fedora/f${SURFACE_RELEASEVER:?not set in the Containerfile}/" \
    "linux-surface.skip_if_unavailable=0"

### Install Surface Linux Kernel & akmods
dnf5 install -y --allowerasing kernel-surface kernel-surface-devel akmods

### Install Surface Linux Utilities
dnf5 install -y iptsd

rm -rf /tmp/* /var/tmp/*

