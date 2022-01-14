#!/bin/bash

yes | sh <(curl -L https://nixos.org/nix/install) --daemon

echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

# neue shell

nix-shell -p nix-info --run "nix-info -m"

nix build .#darwinConfigurations.bootstrap.system
sudo rm /etc/nix/nix.conf
./result/sw/bin/darwin-rebuild switch --flake .#bootstrap

# neue shell, ab hier regulärer workflow

darwin-rebuild switch --flake .#mbrasch
