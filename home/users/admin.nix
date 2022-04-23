{ config, pkgs, ... }:
let
  name = "Admin";
  email = "mike@mbrasch.de";
  key = "";
  home_directory = "${config.home.homeDirectory}";

in {
  imports = [ ./shells.nix ];


  #################################################################################################



  home = {
    sessionVariables = {
      EDITOR = "${pkgs.nano}/bin/nano";
      #EMAIL = "${config.programs.git.userEmail}";
      PAGER = "${pkgs.less}/bin/less";
      CLICOLOR = true;
      GPG_TTY = "$TTY";
      #PATH = "$PATH:$HOME/.local/bin:$HOME/.tfenv/bin";
    };

    services = {

    };

    programs = {
      home-manager = { enable = true; };

      direnv = {
        enable = true;
        nix-direnv = { enable = true; };
      };

      dircolors = {
        enable = true;
        enableZshIntegration = true;
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
