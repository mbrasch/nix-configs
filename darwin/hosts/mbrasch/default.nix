{ config, pkgs, ... }:
let
  tmp_directory = "/tmp";

in {
  imports = [  ];


  #################################################################################################
  # nix specific settings

  nix = {
    trustedUsers = [ "@admin" ];
    #package = pkgs.nixVersions.unstable; # war: nixFlakes

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-derivations = true
      keep-outputs = true
    '';

    binaryCaches = [
      "https://cache.nixos.org/"
      #"https://hydra.iohk.io"
      #"https://iohk.cachix.org"
    ];

    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      #"hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      #"iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
    ];
  };

  services = {
    nix-daemon.enable = true;
    activate-system.enable = true;
  };

  users.nix.configureBuildUsers = true;

  system.stateVersion = 4;
  }


  #################################################################################################

  environment = {
    systemPackages = with pkgs;
      [
        #terminal-notifier
        #alacritty
      ];
  };


  #################################################################################################


  system = {
    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 20;
        KeyRepeat = 1;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        NSDisableAutomaticTermination = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;

        NSScrollAnimationEnabled = true;
        NSTableViewDefaultSizeMode = 1; # 1 small, 2 medium, 3 large
        NSWindowResizeTime = "0.20";
        _HIHideMenuBar = false;

        # com.apple = {
        #   keyboard.fnState = true; # false = F-keys
        #   mouse.tapBehavior = 1; # null or 1 for tap to click
        #   sound.beep.feedback = 0; # 1 = audio feedback when changing volume
        #   sound.beep.volume = "0.0"; # 0.0 to 1.0
        #   springing.enabled = true;
        #   springing.delay = "1.0";
        #   swipescrolldirection = true; # true = natural direction
        #   trackpad.enableSecondaryClick = true;
        # };
      };

      dock = {
        autohide = true;
        autohide-delay = "0.25";
        autohide-time-modifier = "1.0";
        dashboard-in-overlay = true; # true = hide dashboard

        expose-animation-duration = "1.0";
        expose-group-by-app = true;

        launchanim = true;
        orientation = "bottom"; # "bottom", "left", "right" or null
        enable-spring-load-actions-on-all-items = true;
        mineffect = "scale"; # "genie", "suck", "scale" or null
        minimize-to-application = false;
        mouse-over-hilite-stack = true;
        mru-spaces = false; # true = automatically rearrange spaces based on most recent use
        show-process-indicators = true;
        show-recents = false;
        showhidden = true;
        static-only = false; # true = show only open applications
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      loginwindow = {
        DisableConsoleAccess = false;
        GuestEnabled = false;
        LoginwindowText = "Die Power von nix.";
        PowerOffDisabledWhileLoggedIn = false;
        RestartDisabled = false;
        RestartDisabledWhileLoggedIn = false;
        SHOWFULLNAME = false; # true = login via name and password field
        ShutDownDisabled = false;
        ShutDownDisabledWhileLoggedIn = false;
        SleepDisabled = false;
        autoLoginUser = null;
      };

      screencapture = {
        location = null; # path as string
        disable-shadow = false;
      };

      trackpad = {
        ActuationStrength = 1; # 0 = silent clicking
        Clicking = true; # 1 = tap to click
        FirstClickThreshold =
          null; # normal click: 0 for light clicking, 1 for medium, 2 for firm
        SecondClickThreshold =
          null; # force touch: 0 for light clicking, 1 for medium, 2 for firm
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      # keyboard = {
      #   enableKeyMapping = false;
      #   nonUS.remapTilde = false;
      #   remapCapsLockToControl = true;
      #   remapCapsLockToEscape = false;
      # };
    };

    # Copy applications into ~/Applications/Nix Apps. This workaround allows us to find applications installed by nix through spotlight.
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


  #################################################################################################


  nix-index.enable = true;
  info.enable = true;
  man.enable = true;


  #################################################################################################


  programs = {
    gnupg.agent = {
      enable = false;
      enableSSHSupport = true;
    };

    bash = { enable = true; };
    zsh = { enable = true; };
  };


  #################################################################################################


  packages = with pkgs; [
    ##### Nix stuff #####

    nix-top                         # Tracks what nix is building
    nix-du                          # A tool to determine which gc-roots take space in your nix store   ???>   build error: No such file or directory (os error 2)
    nix-diff                        # Explain why two Nix derivations differ
    nix-index                       # A files database for nixpkgs
    nix-tree                        # Interactively browse a Nix store paths dependencies
    nix-bundle                      # Create bundles from Nixpkgs attributes
    nix-linter                      # Linter for Nix(pkgs), based on hnix   ???>   build error: Encountered missing or private dependencies: hnix ==0.6.*
    #nix-plugins                     # Collection of miscellaneous plugins for the nix expression language   ???>   build failure
    nix-review                      # Review pull-requests on https://github.com/NixOS/nixpkgs
    #nix-serve                       # A utility for sharing a Nix store as a binary cache
    nixfmt                          # An opinionated formatter for Nix
    nixbang                         # A special shebang to run scripts in a nix-shell
    vulnix                          # NixOS vulnerability scanner
    #nix-doc                         # ???>   build failure
    nix-template

    #disnix                          # A Nix-based distributed service deployment tool
    #disnixos                        # Provides complementary NixOS infrastructure deployment to Disnix
    #dysnomia                        # Automated deployment of mutable components and services for Disnix

    #nixopsUnstable                  # NixOS cloud provisioning and deployment tool
    #nixops-dns                      # DNS server for resolving NixOps machines
    morph
    lorri                           # Your project's nix-env
    niv                             # Easy dependency management for Nix projects

    nixpkgs-lint                    # A utility for Nixpkgs contributors to check Nixpkgs for common errors
    nixpkgs-fmt                     # Nix code formatter for nixpkgs
    nixpkgs-review                  # Review pull-requests on https://github.com/NixOS/nixpkgs

    nixos-generators

    ##### containerization stuff #####

    #docker                          # An open source project to pack, ship and run any application as a lightweight container
    #docker-compose                  # Multi-container orchestration for Docker
    #docker-machine                  # Docker Machine is a tool that lets you install Docker Engine on virtual hosts, and manage Docker Engine on the hosts
    #linuxkit                        # A toolkit for building secure, portable and lean operating systems for containers
    #ansible                         # Radically simple IT automation
    #ansible-lint                    # Best practices checker for Ansible
    #vagrant                         # A tool for building complete development environments
    #terraform                       # Tool for building, changing, and versioning infrastructure
    #packer                          # A tool for creating identical machine images for multiple platforms from a single source configuration
    #hashi-ui                        # A modern user interface for hashicorp Consul & Nomad
    #nomad                           # A Distributed, Highly Available, Datacenter-Aware Scheduler
    #consul                          # Tool for service discovery, monitoring and configuration
    #mkpasswd                        # unsopported system

    ###### zsh / shell stuff ######

    zsh-autoenv
    zsh-autosuggestions
    zsh-command-time
    zsh-completions
    zsh-git-prompt
    zsh-history-substring-search
    zsh-navigation-tools
    zsh-prezto
    zsh-syntax-highlighting
    nix-zsh-completions
    nix-bash-completions
    oh-my-zsh
    antibody                        # shell plugin manager
    mosh                            # mobile shell
    shellcheck
    shfmt
    #fish

    ###### services stuff ######

    davmail

    ##### modern alternatives to old tools #####

    fd                              # find
    bat                             # cat
    exa                             # ls
    lsd                             # ls
    procs                           # ps
    broot                           # tree
    sd                              # sed
    #dust                           # du   ->   runtime error: -jit/bin/pixie-vm: No such file or directory
    ripgrep                         # grep
    hyperfine                       # benchmarking (-> time)
    glances                         # top
    gtop                            # top
    gping                           # ping
    xh                              # HTTPie, sending http requests
    dog                             # dig


    ##### network stuff #####

    openssh
    mtr                             # A network diagnostics tool
    nmap                            # A free and open source utility for network discovery and security auditing
    #ntopng                         # High-speed web-based traffic analysis and flow collection tool   ???>   build error: comparison between pointer and integer ('char *' and 'char')
    #nethogs                        # A small 'net top' tool, grouping bandwidth by process (not darwin)
    #nload                          # Monitors network traffic and bandwidth usage with ncurses graphs   ???>   linux only
    iperf                           # Tool to measure IP bandwidth using UDP or TCP
    #slurm                          # Simple Linux Utility for Resource Management    ???>   linux only
    #iproute                        # A collection of utilities for controlling TCP/IP networking and traffic control in Linux   ???>   linux only
    iftop                           # Display bandwidth usage on a network interface
    dnstop                          # libpcap application that displays DNS traffic on your network
    dnsperf                         # Tools for DNS benchmaring
    #gotop                           # A terminal based graphical activity monitor inspired by gtop and vtop   ???>   marked broken
    coreutils				                # The basic file, shell and text manipulation utilities of the GNU operating system
    #ocrmypdf                       # Adds an OCR text layer to scanned PDF files, allowing them to be searched   ???>   "Unsupported OS"
    #thefuck                        # Magnificent app which correct your previous console command
    #ngrep                          # Network packet analyzer   ->   Linux only
    #mitmproxy                       # Man-in-the-middle proxy   ???>   build failure
    #p0f                            # Passive network reconnaissance and fingerprinting tool   ???>   failed with exit code 2;
    #endlessh                       # SSH tarpit that slowly sends an endless banner
    #duplicati                      # A free backup client that securely stores encrypted, incremental, compressed backups on cloud storage services and remote file servers
    #wireguard-go                   # Userspace Go implementation of WireGuard
    #boringtun                      # Userspace WireGuard?? implementation in Rust
    wireguard-tools                 # Tools for the WireGuard secure network tunnel
    #gogs					                  # A painless self-hosted Git service
    #magic-wormhole                 # Securely transfer data between computers
    #croc                           # Securely transfer data between computers
    tmux

    ###### language stuff ######

    #--- python

    (python3.withPackages (p: with p; [ pip jinja2 protobuf passlib pyfritzhome ]))

    #--- php

    php                            # no withPackages
    phpExtensions.mbstring

    #--- javascript

    nodejs

    #--- perl

    #(perl.withPackages  (p: with p; [ IO ]))

    #--- ruby

    (ruby.withPackages (p: with p; [ cocoapods ]))
    bundix                          # package your Bundler-enabled Ruby applications with the Nix package manager.

    #--- misc

    adoptopenjdk-openj9-bin-11
    autoconf
    go
    go-langserver
    (lua.withPackages (p: with p; [ luarocks mpack ]))
    jq

    ###### other stuff ######

    tokei                           # statistic over code
    tealdeer                        # tldr
    bandwhich                       # network utilization by process
    grex                            # A command-line tool for generating regular expressions from user-provided test cases
    git
    file                            # A program that shows the type of files
    htop                            # An interactive process viewer
    ffmpeg                          # A complete, cross-platform solution to record, convert and stream audio and video
    flvstreamer                     # Command-line RTMP client
    tesseract4                      # OCR engine
    yt-dlp                          # Command-line tool to download videos from YouTube.com and other sites
    pandoc                          # Conversion between markup formats
    graphviz
    #espanso
  ];


  #################################################################################################


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
    ];

    brews = [
      "iproute2mac"
    ];

  };
}
