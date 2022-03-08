{ config, pkgs, ... }:
let
  name = "Mike Brasch";
  email = "mikebrasch@fastmail.fm";
  key = "mikebrasch@github";
  home_directory = "${config.home.homeDirectory}";

in {
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
