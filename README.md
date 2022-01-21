# nix-configs
My personal Nix and Git playground – everything just stolen


## initial install

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



## regular use

**rebuild config**

```shell
darwin-rebuild switch --flake .#mbrasch
```

**update packages**

```shell
nix flake update .#mbrasch
```


## troubleshooting

sometimes a macos update overwrites /etc/bashrc and /etc/zshrc. then you can fix it via appending:

```shell
# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
```

## notes

```shell
~~> Setting up shell profiles: /etc/bashrc /etc/profile.d/nix.sh /etc/zshrc /etc/bash.bashrc /etc/zsh/zshrc
```

```
darwin-rebuild switch --flake ssh+git://git@github.com:mbrasch/nix-configs#mbrasch
```
