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

cp -r /usr/share/ublue-os/bazaar /etc

sed -i 's|/usr/share/ublue-os/|/run/host/etc/|g' /etc/bazaar/config.yaml

systemctl --global enable bazaar.service

dnf5 -y copr enable ublue-os/flatpak-test

dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper

dnf5 -y copr disable ublue-os/flatpak-test

rpm -qa --qf "%{NAME} %{VENDOR}\n" | grep -i copr

systemctl enable flatpak-preinstall.service

dnf5 install -y \
  mpdris2 \
  neovim \

# nvim packaging fucks me over
# https://bugzilla.redhat.com/show_bug.cgi?id=2402743
rm /.nvimlog


# Replace nvim with vim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi
