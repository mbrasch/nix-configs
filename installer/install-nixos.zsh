#!/usr/bin/env nix-shell
#!nix-shell -i zsh -p jq nixUnstable

zmodload zsh/zutils

# if [ ! -d "/etc/nixos" ]; then
#   print "This script can only run from NixOS."; exit 1;
# fi

DISK=/dev/sda
PARTPREFIX="-disk"
OUTPUT=""

RED='\033[1;31m'
NORMAL='\033[0;39m'



usage() {
  print ""
  print "Usage:"
  print "$(basename $0) [ -d <device name> ] -o <output name>"
  print "Example: $(basename $0) -d /dev/sdb -o myserver"
  print ""
  print "Device name: when omitted it defauls to /dev/sda."
  print "Output name: Querying the flake reveals the following ${#FLAKEOUTPUTS[@]} NixOS configurations:"
  print "\t${FLAKEOUTPUTS[*]}"
  exit 1
}



welcome() {
  print "NixOS installer"
  print "==============="
  print "This script will bootstrap a new NixOS system from a given configuration. According to the options given, it will do the following:"
  print ""
  print "   * zapping the target disk ${RED}${DISK}${NORMAL}"
  print "   * creating 3 partitions (BIOS, EFI and system)"
  print "   * formatting the partitions (ZFS for system partition)"
  print "   * cloning configuration from git repository"
  print "   * installing your configuration ${RED}${OUTPUT}${NORMAL}"
  print "   * rebooting into new system"
  print ""
  print "Are you OK with this? Press ENTER to going further or CTRL+C to abort."
  read -r _
}



partitioning() {
  print "zapping…"
  #sgdisk --zap-all "${DISK}"

  print "creating BIOS partition…"
  #sgdisk -a1 -n2:34:2047 -t2:EF02 ${DISK}

  print "creating EFI partition…"
  #sgdisk -n3:1M:+512M -t3:EF00 "${DISK}"

  # Main ZFS partition, using up the remaining space on the drive
  print "creating ZFS partition…"
  #sgdisk -n1:0:0 -t1:BF01 "${DISK}"
}


createfilesystems() {
  print "creating zpool…"
  #zpool create -O mountpoint=none -O atime=off -O compression=lz4 -O xattr=sa -O acltype=posixacl -o ashift=12 -R /mnt rpool "${DISK}${PARTPREFIX}1" -f

  print "creating filesystems…"
  #zfs create -o mountpoint=none rpool/root
  #zfs create -o mountpoint=legacy rpool/root/nixos
  #zfs create -o mountpoint=legacy rpool/home

  print "mounting filesystems…"
  #mount -t zfs rpool/root/nixos /mnt
  #mkdir /mnt/home
  #mount -t zfs rpool/home /mnt/home

  print "creating EFI filesystem…"
  #mkfs.vfat "${DISK}${PARTPREFIX}3"
  #mkdir /mnt/boot
  #mount "${DISK}${PARTPREFIX}3" /mnt/boot
}



readarray -t FLAKEOUTPUTS < <(nix flake show --json | jq -r '.nixosConfigurations | keys | .[]')

# optstring="hd:o:"
#
# while getopts ${optstring} opt; do
#   case ${opt} in
#     h) usage;;
#     d) DISK=${OPTARG};;
#     o) if print '%s\n' "${FLAKEOUTPUTS[@]}" | grep -qFx -- "$OPTARG"; then
#          OUTPUT=${OPTARG}
#        else
#          print "Given flake output ${RED}${OPTARG}${NORMAL} does not exist.\n"
#          usage
#        fi;;
#     #*) echo "******** ${OPTARG}.";exit 1 ;;
#   esac
# done

zparseopts



welcome
partitioning
createfilesystems

#print "Installing nix unstable…"
#nix-env -iA nixos.nixUnstable

#print "Generating config…"
#nixos-generate-config --root /mnt

print "Cloning configuration from git…"
#git clone https://github.com/mbrasch/nix-configs.git /mnt/etc/nixos
#cd /mnt/etc/nixos


print "Installing NixOS…"
#nixos-install --flake "/mnt/etc/nixos/.#${OUTPUT}"
