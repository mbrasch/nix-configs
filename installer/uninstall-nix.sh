#!/bin/bash

set -euxo pipefail

echo "*** uninstalling launchdeamons…"
sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist
sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist

sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist

sudo launchctl unload /Library/LaunchDaemons/org.nixos.activate-system.plist
sudo rm /Library/LaunchDaemons/org.nixos.activate-system.plist

echo "*** deleting nix-related folders…"
sudo rm -rf /etc/nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

echo "*** removing nixbld users…"
sudo dscl . delete /Groups/nixbld
for i in $(seq 1 32); do sudo dscl . -delete /Users/_nixbld$i; done

echo "*** delete nix store volume…"
sudo diskutil apfs deleteVolume /nix
sudo rm -rf /nix/

echo "*** restoring original /bashrc…"
sudo mv -fv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc

echo "*** restoring original /zshrc…"
sudo rm -v /etc/zshrc.before_nix-darwin
sudo mv -fv /etc/zshrc.backup-before-nix /etc/zshrc

echo "Nix should now be completely removed."
