#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git     # @TODO: warum wird git nicht installiert?

set -euo pipefail

if [ ! -d "/etc/nixos" ] || [ ! -d "/iso/isolinux/" ]; then
  echo -e "This script can only run from NixOS installer media."; exit 1;
fi


DISK="/dev/vda"      # target device
FILESYSTEM="ext4"    # @TODO: target filesystem: ext4 || zfs
OUTPUT=""            # @TODO: output derivation (flakes)

RED='\033[1;31m'
NORMAL='\033[0;39m'


#echo -e "Changing nix-channel to nixos-unstable…"
#nix-channel --add https://nixos.org/channels/nixos-unstable nixos
#nix-channel --update

echo -e "Installing some requirements…"
nix-env -iA nixos.git



usage() {
  echo -e ""
  echo -e "Usage:   $(basename $0) -d <device name> -f <filesystem>"
  echo -e "Example: $(basename $0) -d /dev/sdb -f zfs"
  echo -e ""
  echo -e "Filesystem could be: zfs or ext4"
  echo -e ""
  echo -e "Device name:"
  lsblk -f
  exit 1
}



welcome() {
  echo -e "NixOS installer"
  echo -e "==============="
  echo -e ""
  echo -e "NixOS $(nixos-version), $(nix --version)"
  echo -e ""
  echo -e "This script will bootstrap a new NixOS system from a given configuration. According to the options given, it will do the following:"
  echo -e ""
  echo -e "   * zapping the target disk ${RED}${DISK}${NORMAL}"
  echo -e "   * creating 2 partitions (EFI and system)"
  echo -e "   * formatting the partitions (ZFS for system partition)"
  echo -e "   * cloning configuration from git repository"
  echo -e "   * installing your static minimal configuration ${RED}/nixos/hosts/minimal${NORMAL}"
  echo -e ""
  echo -e "Are you OK with this? Press ENTER to going further or CTRL+C to abort."
  read -r _
}



partitioning() {
  echo -e "zapping ${DISK}…"
  sgdisk --zap-all "${DISK}"

  echo -e "creating EFI partition…"
  sgdisk -n2:1M:+512M -t2:EF00 "${DISK}"

  echo -e "creating ZFS partition…"
  sgdisk -n1:0:0 -t1:BF01 "${DISK}"
}



createfilesystems_zfs() {
  echo -e "creating zpool…"
  zpool create -O mountpoint=none -O atime=off -O compression=lz4 -O xattr=sa -O acltype=posixacl -o ashift=12 -R /mnt rpool "${DISK}1" -f

  echo -e "creating filesystems…"
  zfs create -o mountpoint=none rpool/root
  zfs create -o mountpoint=legacy rpool/root/nixos
  zfs create -o mountpoint=legacy rpool/home

  echo -e "mounting filesystems…"
  mount -t zfs rpool/root/nixos /mnt
  mkdir /mnt/home
  mount -t zfs rpool/home /mnt/home

  echo -e "creating EFI filesystem…"
  mkfs.vfat "${DISK}2"
  mkdir /mnt/boot
  mount "${DISK}2" /mnt/boot
}



createfilesystems_ext4() {
  echo -e "creating filesystems…"
  mkfs.ext4 -L nixos ${DISK}1
  mkfs.fat -F 32 -n boot ${DISK}2

  echo -e "mounting filesystems…"
  mount ${DISK}1 /mnt
  mkdir -p /mnt/boot
  mount ${DISK}2 /mnt/boot
}



optstring="hd:"

while getopts ${optstring} opt; do
  case ${opt} in
    h) usage;;
    d) if [ -z ${OPTARG} ]; then
         echo -e "No target device given. Defaulting to ${DISK}.\n"
       else
         DISK=${OPTARG}
       fi;;
    #*) echo "******** ${OPTARG}.";exit 1 ;;
  esac
done


welcome
partitioning
createfilesystems_ext4


echo -e "Cloning configuration from git…"
git clone https://github.com/mbrasch/nix-configs.git

echo -e "Generating hardware config…"
nixos-generate-config --root /mnt

echo -e "Copying minimal config to /mnt/etc/nixos/ …"
cp -f nix-configs/nixos/hosts/minimal/default.nix /mnt/etc/nixos/configuration.nix

echo -e "Installing NixOS…"
nixos-install --no-root-passwd

echo -e "Installer completed. You can now reboot your machine or check the configuration."
