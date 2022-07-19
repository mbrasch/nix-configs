#!/bin/bash

set -euxo pipefail

echo -e ""
echo -e "Installing nix-darwin from bootstrap-flake…"
echo -e ""

nix build --flake github:mbrasch/nix-configs#darwinConfigurations.bootstrap.system

sudo rm /etc/nix/nix.conf  # otherwise darwin-rebuild will fail to create a symlink to the generated nix config
echo 'run\tprivate/var/run' | sudo tee -a /etc/synthetic.conf
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

./result/sw/bin/darwin-rebuild switch --flake .#bootstrap

echo -e ""
echo -e "done."
echo -e "You need to open a new shell session."
echo -e ""
echo -e "Now you can install preferred configuration like this:"
echo -e ""
echo -e "     darwin-rebuild switch --flake github:mbrasch/nix-configs#mbrasch"
echo -e ""
echo -e "Or you simply startover with this minimal configuration:"
echo -e ""
echo -e "     darwin-rebuild edit"
echo -e "             and"
echo -e "     darwin-rebuild switch"


