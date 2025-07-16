#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1


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

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable ublue-os/staging

# Replace nvim with vim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi

#### Example for enabling a System Unit File

systemctl enable podman.socket

#KERNEL_PIN=

dnf5 versionlock delete kernel{,-core,-modules,-modules-core,-modules-extra,-tools,-tools-lib,-headers,-devel,-devel-matched}

dnf5 -y remove kernel{,-core,-modules,-modules-core,-modules-extra,-tools,-tools-lib,-headers,-devel,-devel-matched}

dnf5 -y remove kmod-framework-laptop kmod-xone kmod-openrazer


if [[ -z "${KERNEL_PIN:-}" ]]; then
    # installs coreos kernel
    KERNEL=$(skopeo inspect --retry-times 3 docker://ghcr.io/ublue-os/akmods:coreos-stable-"$(rpm -E %fedora)" | jq -r '.Labels["ostree.linux"]')
else
    # Install the pinned kernel if KERNEL_PIN is specified
    KERNEL=$(skopeo inspect --retry-times 3 docker://ghcr.io/ublue-os/akmods:coreos-stable-"$(rpm -E %fedora)"-${KERNEL_PIN} | jq -r '.Labels["ostree.linux"]')
fi

skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:coreos-stable-"$(rpm -E %fedora)"-${KERNEL} dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods/"$AKMODS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/

dnf5 -y install /tmp/kernel-rpms/kernel-{core,modules,modules-core,modules-extra}-"${KERNEL}".rpm
# CoreOS doesn't do kernel-tools, removes leftovers from newer kernel
dnf5 -y remove kernel-tools{,-libs}


# Everyone
# NOTE: we won't use dnf5 copr plugin for ublue-os/akmods until our upstream provides the COPR standard naming
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
AKMODS=(
    /tmp/akmods/kmods/*xone*.rpm
    /tmp/akmods/kmods/*framework-laptop*.rpm
    /tmp/akmods/kmods/*openrazer*.rpm
)
dnf5 -y install "${AKMODS[@]}"


dnf5 versionlock add kernel{,-core,-modules,-modules-core,-modules-extra,-tools,-tools-lib,-headers,-devel,-devel-matched}

