# This module defines a small NixOS installation CD. It does not contain any graphical stuff.
#
# Build with:
#
#     nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=build-nixos-installer-iso.nix
#

{config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # configure proprietary drivers
  nixpkgs.config.allowUnfree = true;

  boot = {
    initrd.kernelModules = [ "wl" ];
    kernelModules = [ "kvm-intel" "wl" ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    kernelParams = [
      "console=tty1"
      "console=ttyS0,115200"
    ];
  };

  # programs that should be available in the installer
  environment.systemPackages = with pkgs; [
    zsh
    git
  ];
}
