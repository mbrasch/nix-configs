#!/usr/bin/env nix-shell
#!nix-shell -p git

set -euo pipefail

nix --version
git --version

if [ ! -d "/etc/nixos" ] || [ ! -d "/iso/isolinux/" ]; then
  echo -e "This script can only run from NixOS installer media."; exit 1;
fi


DISK="/dev/sda"
DEFAULT_DISK="/dev/sda"
PARTPREFIX=""
OUTPUT=""

RED='\033[1;31m'
NORMAL='\033[0;39m'



usage() {
  echo -e ""
  echo -e "Usage:   $(basename $0) -d <device name>"
  echo -e "Example: $(basename $0) -d /dev/sdb"
  echo -e ""
  echo -e "Device name:"
  lsblk -f
  exit 1
}



welcome() {
  echo -e "NixOS installer"
  echo -e "==============="
  echo -e "This script will bootstrap a new NixOS system from a given configuration. According to the options given, it will do the following:"
  echo -e ""
  echo -e "   * zapping the target disk ${RED}${DISK}${NORMAL}"
  echo -e "   * creating 3 partitions (BIOS, EFI and system)"
  echo -e "   * formatting the partitions (ZFS for system partition)"
  echo -e "   * cloning configuration from git repository"
  echo -e "   * installing your static minimal configuration ${RED}/nixos/hosts/minimal${NORMAL}"
  echo -e "   * rebooting into new system"
  echo -e ""
  echo -e "Are you OK with this? Press ENTER to going further or CTRL+C to abort."
  read -r _
}



partitioning() {
  echo -e "zapping…"
  sgdisk --zap-all "${DISK}"

  echo -e "creating BIOS partition…"
  sgdisk -a1 -n2:34:2047 -t2:EF02 ${DISK}

  echo -e "creating EFI partition…"
  sgdisk -n3:1M:+512M -t3:EF00 "${DISK}"

  # Main ZFS partition, using up the remaining space on the drive
  echo -e "creating ZFS partition…"
  sgdisk -n1:0:0 -t1:BF01 "${DISK}"

  partprobe ${DISK}
}


createfilesystems() {
  echo -e "creating zpool…"
  zpool create -O mountpoint=none -O atime=off -O compression=lz4 -O xattr=sa -O acltype=posixacl -o ashift=12 -R /mnt rpool "${DISK}${PARTPREFIX}1" -f

  echo -e "creating filesystems…"
  zfs create -o mountpoint=none rpool/root
  zfs create -o mountpoint=legacy rpool/root/nixos
  zfs create -o mountpoint=legacy rpool/home
}

mountfilesystems() {
  echo -e "mounting filesystems…"
  mount -t zfs rpool/root/nixos /mnt
  mkdir /mnt/home
  mount -t zfs rpool/home /mnt/home

  echo -e "creating EFI filesystem…"
  mkfs.vfat "${DISK}${PARTPREFIX}3"
  mkdir /mnt/boot
  mount "${DISK}${PARTPREFIX}3" /mnt/boot
}

optstring="hd:"

while getopts ${optstring} opt; do
  case ${opt} in
    h) usage;;
    d) if [ -z ${OPTARG} ]; then
         echo -e "No target device given. Defaulting to ${DEFAULT_DISK}.\n"
       else
         DISK=${OPTARG}
       fi;;
    #*) echo "******** ${OPTARG}.";exit 1 ;;
  esac
done


welcome
#partitioning
#createfilesystems
mountfilesystems

echo -e "Cloning configuration from git…"
git clone https://github.com/mbrasch/nix-configs.git

echo -e "Copying minimal confi to /mnt/etc/nixos/ …"
cp /nixos/hosts/minimal/default.nix /mnt/etc/nixos/configuration.nix


echo -e "Generating config…"
nixos-generate-config --root /mnt


echo -e "Installing NixOS…"
nixos-install --no-root-passwd

echo -e "Installer completed. You can now reboot your machine."
