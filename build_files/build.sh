#!/bin/bash

set -ouex pipefail

rsync -rvK /ctx/system_files/ /

dnf5 remove -y \
  vim-minimal \
  vim-enhanced \
  nano-default-editor \
  vim-data

dnf5 install -y \
  mpdris2 \
  neovim \

# Replace nvim with vim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi
