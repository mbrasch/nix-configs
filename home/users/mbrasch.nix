{ config, pkgs, ... }:
let
  name = "Mike Brasch";
  email = "mike@mbrasch.de";
  key = "mbrasch@github";
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


    #################################################################################################


    services = {
      # yabai = {
      #   enable = false;
      #   package = pkgs.yabai;
      #   enableScriptingAddition = true;
      #   config = {
      #     window_placement = "second_child";
      #     window_topmost = "off";
      #     window_opacity = "off";
      #     status_bar = "on";
      #     window_border = "on";
      #     window_shadow = "on";
      #     split_ratio = 0.5;
      #     mouse_modifier = "fn";
      #     mouse_action1 = "move";
      #     mouse_action2 = "resize";
      #     mouse_follows_focus = "off";
      #     focus_follows_mouse = "off";
      #     auto_balance = "off";
      #     layout = "bsp";
      #     top_padding = 0;
      #     bottom_padding = 0;
      #     left_padding = 0;
      #     right_padding = 0;
      #     window_gap = 0;
      #     window_border_width = 2;
      #     #active_window_border_color = "red";
      #   };
      #   extraConfig = ''
      #     yabai -m rule --add app="Dash.app" manage=off topmost=on
      #     yabai -m rule --add app="Finder" manage=off topmost=on
      #     yabai -m rule --add app="System Preferences.app" manage=off topmost=on
      #   '';
      # };
    };


    #################################################################################################


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

      # ssh = {
      #   enable = true;
      #   controlMaster = "auto";
      #   controlPath = "${tmp_directory}/ssh-%u-%r@%h:%p";
      #   controlPersist = "1800";
      #   forwardAgent = true;
      #   serverAliveInterval = 60;
      #   hashKnownHosts = true;
      #
      #   extraConfig = ''
      #     #SCE_GROUP:B0713CB6-A009-4E72-AC09-A9DE823B9F60:::Privat
      #     Host BistroServe
      #     User admin
      #     HostName bistroserve
      #     IdentityFile ~/.ssh/private.id.rsa
      #     #SCEIcon home
      #     #SCEGroup B0713CB6-A009-4E72-AC09-A9DE823B9F60
      #     #SCE_GROUP:D34811CE-4F87-4B7F-AFAE-826B9310D5AF:::Serviceware
      #     Host bc-climgmt3.pmcs.de
      #     User mbrasch
      #     IdentityFile ~/.ssh/serviceware.id.rsa
      #     #SCEIcon suitcase
      #     #SCEGroup D34811CE-4F87-4B7F-AFAE-826B9310D5AF
      #   '';
      # };

      # xdg = {
      #   enable = true;
      #   configHome = "${home_directory}/.config";
      #   dataHome = "${home_directory}/.local/share";
      #   cacheHome = "${home_directory}/.cache";
      # };

      # git = {
      #   userName = "${name}";
      #   userEmail = "${email}";
      #   signing = {
      #     key = "${key}";
      #     signByDefault = true;
      #   };
      #   extraConfig = { github.user = "mbrasch"; };
      # };


      # adb.enable = true;
    };
  };
}
