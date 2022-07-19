#!/usr/bin/env nix-shell --extra-experimental-features flakes --extra-experimental-features nix-command
#!nix-shell jq

set -euo pipefail

nix --version

if [ ! -d "/etc/nixos" ] || [ ! -d "/iso/isolinux/" ]; then
  echo -e "This script can only run from NixOS installer media."; exit 1;
fi

REPOSITORY="github:mbrasch/nix-configs"

DISK=""
PARTPREFIX="-disk"
OUTPUT=""

RED='\033[1;31m'
NORMAL='\033[0;39m'



usage() {
  echo -e ""
  echo -e "Usage:   $(basename $0) -d <device name> -o <output name>"
  echo -e "Example: $(basename $0) -d /dev/sdb -o myserver"
  echo -e ""
  echo -e "Device name:"
  lsblk -f
  echo -e ""
  echo -e "Output name: Querying the flake reveals the following ${#FLAKEOUTPUTS[@]} NixOS configurations:"
  echo -e "\t${FLAKEOUTPUTS[*]}"
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
  echo -e "   * installing your configuration ${RED}${OUTPUT}${NORMAL}"
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
}


createfilesystems() {
  echo -e "creating zpool…"
  zpool create -O mountpoint=none -O atime=off -O compression=lz4 -O xattr=sa -O acltype=posixacl -o ashift=12 -R /mnt rpool "${DISK}${PARTPREFIX}1" -f

  echo -e "creating filesystems…"
  zfs create -o mountpoint=none rpool/root
  zfs create -o mountpoint=legacy rpool/root/nixos
  zfs create -o mountpoint=legacy rpool/home

  echo -e "mounting filesystems…"
  mount -t zfs rpool/root/nixos /mnt
  mkdir /mnt/home
  mount -t zfs rpool/home /mnt/home

  echo -e "creating EFI filesystem…"
  mkfs.vfat "${DISK}${PARTPREFIX}3"
  mkdir /mnt/boot
  mount "${DISK}${PARTPREFIX}3" /mnt/boot
}

readarray -t FLAKEOUTPUTS < <(nix flake show "${REPOSITORY}" --json | jq -r '.nixosConfigurations | keys | .[]')

optstring="hd:o:"

while getopts ${optstring} opt; do
  case ${opt} in
    h) usage;;
    d) if [ -z ${OPTARG} ]; then
         echo -e "No target device given.\n"
         usage
       else
         DISK=${OPTARG}
       fi;;
    o) if [ -z ${OPTARG} ]; then
         echo -e "No flake output given.\n"
         usage
       fi
       if printf '%s\n' "${FLAKEOUTPUTS[@]}" | grep -qFx -- "$OPTARG"; then
         OUTPUT=${OPTARG}
       else
         echo -e "Given flake output ${RED}${OPTARG}${NORMAL} does not exist.\n"
         usage
       fi;;
    #*) echo "******** ${OPTARG}.";exit 1 ;;
  esac
done



welcome
partitioning
createfilesystems

echo -e "Cloning configuration from git…"
git clone https://github.com/mbrasch/nix-configs.git /mnt/etc/nixos
cd /mnt/etc/nixos

#echo -e "Installing nix unstable…"
#nix-env -iA nixos.nixUnstable


echo -e "Generating config…"
nixos-generate-config --root /mnt



echo -e "Installing NixOS…"
nixos-install --extra-experimental-features flakes --extra-experimental-features nix-command --flake "/mnt/etc/nixos/.#${OUTPUT}" --no-root-passwd
