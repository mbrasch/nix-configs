# nix-configs
This repo is not a good example. It is a very experimental repo and its use could cause an unprecedented catastrophe - so be warned.

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

nix build .#darwinConfigurations.bootstrap.system
sudo rm /etc/nix/nix.conf
sudo -i ./result/sw/bin/darwin-rebuild switch --flake .#bootstrap
```

*new shell*

```shell
darwin-rebuild switch --flake .#mbrasch
```

### Regular use

**rebuild config**

```shell
darwin-rebuild switch --flake .#mbrasch
```

**update packages**

```shell
nix flake update .#mbrasch
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
...

### Regular use
...


# Notes to myself

```shell
~~> Setting up shell profiles: /etc/bashrc /etc/profile.d/nix.sh /etc/zshrc /etc/bash.bashrc /etc/zsh/zshrc
```

```
darwin-rebuild switch --flake ssh+git://git@github.com:mbrasch/nix-configs#mbrasch
```

```
nix-tree
nix-locate bin/ping
nix show-derivation nixpkgs#legacyPackages.x86_64-darwin.inetutils
```
