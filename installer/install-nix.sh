#!/bin/bash

set -euxo pipefail

echo -e ""
echo -e "Installing Nix…"
echo -e ""
yes | sh <(curl -L https://nixos.org/nix/install) --daemon
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

echo -e ""
echo -e "done."
echo -e "You need to open a new shell session. Now you are ready to install nix-darwin and/or home-manager if you want."
