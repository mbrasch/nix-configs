# nix-configs
My personal Nix and Git playground – everything just stolen. This repo is not a good example. Major changes will happen all the time.
It is a single experiment and using it could cause an unprecedented disaster - so be warned.

However, if you have any suggestions for improvement or the like, please let us know.


## Darwin

### Initial install
```shell
# install Apple Command Line Developer Tools
xcode-select --install
```

```shell
yes | sh <(curl -L https://nixos.org/nix/install) --daemon
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

*new shell*

```shell
# optional for testing nix
nix-shell -p nix-info --run "nix-info -m"
```

```shell
nix build github:mbrasch/nix-configs#darwinConfigurations.bootstrap-darwin.system
sudo rm /etc/nix/nix.conf                      # otherwise darwin-rebuild will fail to create a symlink to the generated nix config
echo 'run\tprivate/var/run' | sudo tee -a /etc/synthetic.conf
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
./result/sw/bin/darwin-rebuild switch --flake .#bootstrap
```

*new shell*

```shell
darwin-rebuild switch --flake github:mbrasch/nix-configs#mbrasch
```

### Regular use

**rebuild config**

```shell
darwin-rebuild switch --flake github:mbrasch/nix-configs#mbrasch
```

**update packages**

```shell
nix flake update github:mbrasch/nix-configs#mbrasch
```

### Troubleshooting

sometimes a macos update overwrites /etc/bashrc and /etc/zshrc. then you can fix it via appending:

```shell
# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
```


## NixOS

### Flakeless install
Setup and install a NixOS with config /NixOS/hosts/minimal on ZSH.

```bash
sh <(curl -L https://raw.githubusercontent.com/mbrasch/nix-configs/main/installer/install-nixos-flakeless.sh)
```

### Install via flakes

#### Initial install
The following script will prepare sda for installation.

```bash
sh <(curl -L https://raw.githubusercontent.com/mbrasch/nix-configs/main/installer/install-nixos.sh)
```
It will then let you edit the configuration. After closing the editor, the installation process will begin immediately. At the end
you will be asked for the new root password. Afterwards you can reboot into the new system. **Don't forget to set the passwords for
the user accounts created.**

##### Prepare filesystems
```bash
export DISK=/dev/sda
export PARTPREFIX=""

# create partitions
sgdisk --zap-all "${DISK}"
sgdisk -n3:1M:+512M -t3:EF00 "${DISK}"
sgdisk -n1:0:0 -t1:BF01 "${DISK}"

# create zpool
zpool create -O mountpoint=none -O atime=off -O compression=lz4 -O xattr=sa -O acltype=posixacl -o ashift=12 -R /mnt rpool "${DISK}${PARTPREFIX}1"

# create filesystems
zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy rpool/home

# mount filesystems
mount -t zfs rpool/root/nixos /mnt
mkdir /mnt/home
mount -t zfs rpool/home /mnt/home

# create EFI partition
mkfs.vfat "${DISK}${PARTPREFIX}3"
mkdir /mnt/boot
mount "${DISK}${PARTPREFIX}3" /mnt/boot
```

##### Install NixOS
```
nix-env -iA nixos.nixUnstable    # for flake support
nixos-install --flake github:mbrasch/nix-configs#nixosConfigurations.bootstrap.system
```

#### Regular use
```
nixos-rebuild switch --impure --flake github:mbrasch/nix-configs#bistroserve
```


# Notes to myself

```shell
~~> Setting up shell profiles: /etc/bashrc /etc/profile.d/nix.sh /etc/zshrc /etc/bash.bashrc /etc/zsh/zshrc

# install min. nixos on zfs:mbrasch/nix-configs#
sh <(curl -L https://github.com/mbrasch/nix-configs/installer/install-nixos.sh)
```

```
darwin-rebuild switch --flake ssh+git://git@github.com:mbrasch/nix-configs#mbrasch
```

```
nix-tree
nix-locate bin/ping
nix show-derivation nixpkgs#legacyPackages.x86_64-darwin.inetutils
realpath $(which nix-build)



```
