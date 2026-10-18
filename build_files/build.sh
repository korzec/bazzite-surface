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
for pkg in kernel kernel{-core,-modules,-modules-core,-modules-extra,-tools-libs,-tools}; do
    if rpm -q "${pkg}" >/dev/null 2>&1; then
        rpm --erase "${pkg}" --nodeps
    fi
done
rm -rf /usr/lib/modules

dnf5 install -y --allowerasing kernel-surface kernel-surface-devel akmods

# Kernel RPM scriptlets create BLS entries that contain GRUB variables.
# bootc generates its own boot entries during deployment; these RPM entries
# can prevent bootc from resolving the kernel and initramfs paths correctly.
rm -rf /boot/loader/entries

### Install Surface Linux Utilities
dnf5 install -y iptsd

rm -rf /tmp/* /var/tmp/*
