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

KERNEL_PIN=6.14.11-300

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

dnf5 versionlock delete kernel{,-core,-modules,-modules-core,-modules-extra,-tools,-tools-lib,-headers,-devel,-devel-matched}

dnf5 -y remove kmod-openrazer kmod-framework-laptop kmod-xone kmodtool kmod-v4l2loopback kmod-zfs kmod-kvmfr


sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
AKMODS=(
    /tmp/akmods/kmods/*xone*.rpm
    /tmp/akmods/kmods/*framework-laptop*.rpm
    /tmp/akmods/kmods/*openrazer*.rpm
)
dnf5 -y install "${AKMODS[@]}"

# RPMFUSION Dependent AKMODS
dnf5 -y install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm

dnf5 -y install \
        v4l2loopback /tmp/akmods/kmods/*v4l2loopback*.rpm

dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release


dnf5 -y install /tmp/kernel-rpms/kernel-{core,modules,modules-core,modules-extra}-"${KERNEL}".rpm

# CoreOS doesn't do kernel-tools, removes leftovers from newer kernel
dnf5 -y remove kernel-tools{,-libs}


# Prevent kernel stuff from upgrading again
dnf5 versionlock add kernel{,-core,-modules,-modules-core,-modules-extra,-tools,-tools-lib,-headers,-devel,-devel-matched}


# Turns out we need an initramfs if we wan't to boot
KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"



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
