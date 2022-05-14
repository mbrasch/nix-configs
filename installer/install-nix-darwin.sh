#!/bin/bash

echo -e ""
echo -e "Installing Nix…"
echo -e ""
yes | sh <(curl -L https://nixos.org/nix/install) --daemon
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

(
  echo -e ""
  echo -e "Installing nix-darwin from bootstrap-flake…"
  echo -e ""

  nix build --flake github:mbrasch/nix-configs#darwinConfigurations.bootstrap.system

  sudo rm /etc/nix/nix.conf  # otherwise darwin-rebuild will fail to create a symlink to the generated nix config
  echo 'run\tprivate/var/run' | sudo tee -a /etc/synthetic.conf
  /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

  ./result/sw/bin/darwin-rebuild switch --flake .#bootstrap
)

echo -e ""
echo -e "done."
echo -e "You need to open new shell session. Then you can install your configuration like this:"
echo -e ""
echo -e "     darwin-rebuild switch --flake github:mbrasch/nix-configs#mbrasch"
