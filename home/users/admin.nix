{ config, pkgs, ... }:
let
  name = "";
  email = "";
  key = "";
  home_directory = "${config.home.homeDirectory}";

in {
  services = {

  };

  programs = {
    # git = {
    #   userName = "${name}";
    #   userEmail = "${email}";
    #   signing = {
    #     key = "${key}";
    #     signByDefault = true;
    #   };
    #   extraConfig = { github.user = "mbrasch"; };
    # };

    nix-index.enable = true;
    info.enable = true;
    man.enable = true;
    #adb.enable = true;
  };
}
