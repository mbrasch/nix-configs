{ config, pkgs, ... }: {
  system = {
    # Copy applications into ~/Applications/Nix Apps. This workaround allows us
    # to find applications installed by nix through spotlight.
    activationScripts.applications.text = pkgs.lib.mkForce (''
      if [[ -L "$HOME/Applications" ]]; then
        rm "$HOME/Applications"
        mkdir -p "$HOME/Applications/Nix Apps"
      fi
      rm -rf "$HOME/Applications/Nix Apps"
      mkdir -p "$HOME/Applications/Nix Apps"
      for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do
        src="$(/usr/bin/stat -f%Y "$app")"
        echo "copying $app"
        cp -rL "$src" "$HOME/Applications/Nix Apps"
      done
    '');
  };

  programs = {
    gnupg.agent = {
      enable = false;
      enableSSHSupport = true;
    };
  };

  homebrew = {
    enable = true;
    autoUpdate = true;
    cleanup = "zap";
    global.brewfile = true;
    global.noLock = true;

    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
    ];

    masApps = {
      Keynote = 409183694;
      "Microsoft Remote Desktop" = 1295203466;
      Numbers = 409203825;
      Pages = 409201541;
    };

    casks = [
      "iterm2"
      "arduino"
      "raspberry-pi-imager"
      "balenaetcher"
      "hammerspoon"
      "firefox"
      "launchcontrol"
      "signal"
      "knockknock"
      "iproute2mac"
    ];

    brews = [ ];

  };
}
