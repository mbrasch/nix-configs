#!/bin/bash

#DISK=/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S2RBNX0J333616J
PARTPREFIX="-disk"

if [ "$1" = "" ]; then
  echo "Script called without target device, selecting /dev/sda"
  DISK=/dev/sda
  PARTPREFIX=""
fi

echo -e " | This script will prepare a disk with ZFS for installing nixos."
echo -e " | First we need to zap $1"
echo -e " | Are you OK with this?"
echo -e " | Press ENTER to going further or CTRL+C to abort."
read -r _
echo -e "zapping…"
sgdisk --zap-all "${DISK}"

# If you need legacy BIOS support
echo -e "creating BIOS partition…"
sgdisk -a1 -n2:34:2047 -t2:EF02 ${DISK}

# If you need EFI support, make an EFI partition
echo -e "creating EFI partition…"
sgdisk -n3:1M:+512M -t3:EF00 "${DISK}"

# Main ZFS partition, using up the remaining space on the drive
echo -e "creating ZFS partition…"
sgdisk -n1:0:0 -t1:BF01 "${DISK}"

# Create the pool. If you want to tweak this a bit and you're feeling adventurous, you might try adding one or
# more of the following additional options:
#
# To disable writing access times:                        -O atime=off
# To enable filesystem compression:                       -O compression=lz4
# To improve performance of certain extended attributes:  -O xattr=sa
# For systemd-journald posixacls are required:            -O acltype=posixacl
# Force 4K sectors (note small 'o'):                      -o ashift=12
#
# The 'mountpoint=none' option disables ZFS's automount machinery; we'll use the normal fstab-based mounting machinery in Linux.
# '-R /mnt' is not a persistent property of the FS, it'll just be used while we're installing.
echo -e "creating zpool…"
zpool create -O mountpoint=none -O atime=off -O compression=lz4 -O xattr=sa -O acltype=posixacl -o ashift=12 -R /mnt rpool "${DISK}${PARTPREFIX}1" -f

# Create the filesystems. This layout is designed so that /home is separate from the root filesystem, as you'll likely want to snapshot
# it differently for backup purposes. It also makes a "nixos" filesystem underneath the root, to support installing multiple OSes if
# that's something you choose to do in future.
echo -e "creating filesystems…"
zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy rpool/home

# Mount the filesystems manually. The nixos installer will detect these mountpoints and save them to /mnt/nixos/hardware-configuration.nix
# during the install process.
echo -e "mounting filesystems…"
mount -t zfs rpool/root/nixos /mnt
mkdir /mnt/home
mount -t zfs rpool/home /mnt/home

# If you need to boot EFI, you'll need to set up /boot as a non-ZFS partition.
echo -e "creating EFI boot partition…"
mkfs.vfat "${DISK}${PARTPREFIX}3"
mkdir /mnt/boot
mount "${DISK}${PARTPREFIX}3" /mnt/boot

echo -e "Now you are ready to nixos-install your system."

nix-env -iA nixos.nixUnstable
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/configuration.nix
nixos-install
