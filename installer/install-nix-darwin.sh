#!/bin/zsh

yes | sh <(curl -L https://nixos.org/nix/install) --daemon

echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

# neue shell
source $HOME/.config/zsh/.zshenv

nix-shell -p nix-info --run "nix-info -m"

nix build .#darwinConfigurations.bootstrap.system
sudo rm /etc/nix/nix.conf
./result/sw/bin/darwin-rebuild switch --flake .#bootstrap

# neue shell, ab hier regulärer workflow
source $HOME/.config/zsh/.zshenv

darwin-rebuild switch --flake .#mbrasch























# /etc/bashrc und /etc/zshrc
#
# # Nix
# if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
#   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
# fi
# # End Nix

