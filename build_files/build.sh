#!/bin/bash

set -ouex pipefail

rsync -rvK /ctx/system_files/ /


dnf5 reinstall libXcursor -y

dnf5 remove -y \
  default-editor \
  nano \
  nano-default-editor \
  vim-minimal \
  vim-enhanced \
  vim-data \
  ptyxis

# Bazaar flatpak migration test
# I also want flatpak master to play around with preinstall

dnf5 -y remove bazaar

dnf5 -y copr enable renner/flatpak-master

dnf5 -y swap flatpak flatpak-0:1.16.1~git20250925

dnf5 -y copr disable renner/flatpak-master

# this installs a package from fedora repos
dnf5 install -y \
  adw-gtk3-theme \
  erofs-utils \
  mpdris2 \
  neovim \

# Replace nvim with vim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi
