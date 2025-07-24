#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

set -ouex pipefail

# List available kernels with:
# skopeo inspect docker://ghcr.io/ublue-os/akmods:coreos-stable-42 | grep coreos-stable-42-6.14



dnf5 reinstall libXcursor -y

dnf5 remove -y \
  default-editor \
  nano \
  nano-default-editor \
  vim-minimal \
  vim-enhanced \
  vim-data \
  ptyxis

# Use a COPR Example:
#
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable ublue-os/staging

# this installs a package from fedora repos
dnf5 install -y \
  adw-gtk3-theme \
  bluefin-backgrounds \
  bazaar \
  krunner-bazaar\
  erofs-utils \
  mpdris2 \
  neovim \

# sudo-rs
# install sudo-rs
dnf5 -y install sudo-rs
ln -sf /usr/bin/su-rs /usr/bin/su
ln -sf /usr/bin/sudo-rs /usr/bin/sudo
ln -sf /usr/bin/visudo-rs /usr/bin/visudo

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable ublue-os/staging

# Replace nvim with vim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi
