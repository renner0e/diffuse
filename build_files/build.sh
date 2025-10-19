#!/bin/bash

set -ouex pipefail

rsync -rvK /ctx/system_files/ /

dnf5 remove -y \
  default-editor \
  nano \
  nano-default-editor \
  vim-minimal \
  vim-enhanced \
  vim-data \
  ptyxis

dnf5 install -y \
  mpdris2 \
  neovim \

# Replace nvim with vim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi
