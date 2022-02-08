# nix-configs
My personal Nix and Git playground – everything just stolen. This repo is not a good example. Major changes will happen all the time.
It is a single experiment and using it could cause an unprecedented disaster - so be warned.

However, if you have any suggestions for improvement or the like, please let us know.


## Darwin

### Initial install

```shell
yes | sh <(curl -L https://nixos.org/nix/install) --daemon
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

*new shell*

```shell
# optional for testing nix
nix-shell -p nix-info --run "nix-info -m"

nix build --flake github:mbrasch/nix-configs#darwinConfigurations.bootstrap.system
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

### Initial install
From running NixOS installer or NixOS System run:
```
nixos-install --flake github:mbrasch/nix-configs#nixosConfigurations.bootstrap.system
```

### Regular use
```
nixos-rebuild switch --flake github:mbrasch/nix-configs#bistroserve
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
