#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1


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

# this installs a package from fedora repos
dnf5 install -y \
  adw-gtk3-theme \
  bluefin-backgrounds \
  erofs-utils \
  mpdris2 \
  neovim \


# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable ublue-os/packages

# Replace nvim with vim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi

#### Example for enabling a System Unit File

systemctl enable podman.socket
