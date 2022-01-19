#!/bin/bash

echo "*** uninstalling nix-darwin…"
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
./result/bin/darwin-uninstaller

echo "*** uninstalling launchdeamon…"
#sudo launchctl unload -w /Library/LaunchDaemons/org.nixos.nix-daemon.plist
#sudo rm -v /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl bootout system/org.nixos.nix-daemon
sudo rm -v /Library/LaunchDaemons/org.nixos.nix-daemon.plist

echo "*** uninstalling nix…"
sudo rm -rfv /etc/nix /etc/static /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels
sudo rm -rfv "${HOME}/.nix-profile" "${HOME}/.nix-defexpr" "${HOME}/.nix-channels"

echo "*** restoring original /bashrc…"
sudo mv -fv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc

echo "*** restoring original /zshrc…"
sudo rm -v /etc/zshrc.before_nix-darwin
sudo mv -fv /etc/zshrc.backup-before-nix /etc/zshrc

echo "*** removing nixbld users…"
for i in {1..32} ; do sudo dscl . delete "/Users/_nixbld$i" ; done

echo "*** delete nix store volume…"
sudo diskutil apfs deleteVolume "Nix Store"

echo "Nix should now be completely removed."
