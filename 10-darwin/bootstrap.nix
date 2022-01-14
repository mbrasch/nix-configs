{ config, pkgs, lib, ... }:

{
  imports = [ ../00-config/shared.nix ];

  nix = { trustedUsers = [ "@admin" ]; };

  services = {
    nix-daemon.enable = true;
    activate-system.enable = true;
  };

  users.nix.configureBuildUsers = true;

  system.stateVersion = 4;
}
