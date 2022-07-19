#!/bin/bash

set -euxo pipefail

echo "*** uninstalling nix-darwin…"
# nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
# ./result/bin/darwin-uninstaller

nix-env --uninstall '*'
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
./result/bin/darwin-uninstaller
