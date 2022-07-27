{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = true;
      systemd-boot.graceful = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [
      "console=ttyS0,115200"
      "console=tty1"
    ];

    initrd = {
      network.enable = true;
      includeDefaultModules = true;
      kernelModules = [];
    };

    #kernelPackages = [
    #  pkgs.zfsUnstable.latestCompatibleLinuxPackages
    #];
  };



  ##############################################################################################################################
  ## Network

  networking = {
    hostName = "minimal";
    hostId = "4a1a5ffb";

    firewall = {
      enable = false;
      allowedTCPPorts = [ 80 ];
      allowedUDPPorts = [ ];
    };
  };

  ##############################################################################################################################
  ## Locale

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  ##############################################################################################################################
  ## Desktop

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  ##############################################################################################################################
  ## Users

  # generate hashed passwords via: mkpasswd -m sha-512

  users.users = {
    root = {
      hashedPassword = "$6$d2r2kNA..v0aWi8I$hOZJku684D/vwVO6R.3XpJtft.WYsEsrPNuaNetBwnaqOlbqM22rSyaXE72NAcW1.R9vQdaa0OIRZIormYgQT.";
    };

    admin = {
      name = "admin";
      hashedPassword = "$6$R9iwd0gKNHlnLKfD$7rtv9iHdjhKATmnMqOdcMvfXuPk.PNbraeIq9alURhgAsW6KDEZg50b8k3jGn/A5QM7qKOFM330.8Q7EEyofX0";
      isNormalUser = true;
      isSystemUser = false;
      createHome = true;
      cryptHomeLuks = null;
      shell = pkgs.zsh;
      group = "users";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      openssh = {
        authorizedKeys = {
          keyFiles = [ ];
          keys = [ ];
        };
      };
      packages = [ ];
      pamMount = { };
      subGidRanges = [ ];
      subUidRanges = [ ];
    };
  };

  ##############################################################################################################################
  ## System packages

  environment.systemPackages = with pkgs; [
    nixos-shell
    nixos-generators
    nixos-option
    home-manager
    htop
    iftop
    wget
    tree
    mosh
    git
    sysstat
    bat
    fzf
    fd
    tmux
    elinks
  ];

  ##############################################################################################################################
  ## Program configurations

  programs = {
    zsh = {
      enable = true;
      #dotDir = ".config/zsh";
      enableCompletion = true;
      enableBashCompletion = false;
      enableGlobalCompInit = true;
      #vteIntegration = false;
      zsh-autoenv.enable = false;

      autosuggestions = {
        enable = true;
        #extraConfig = {   };
        highlightStyle = "fg=cyan";
        #strategy = [ "completion" ]; # history | completion | match_prev_cmd
      };

      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "pattern" "cursor" "root" "line" ];
        patterns = { };
        styles = { };
      };

      histFile = "$HOME/.zsh_history";
      histSize = 10000;

      #promptInit = '''';
      interactiveShellInit = ""; # Shell script code called during interactive zsh shell initialisation.
      loginShellInit = ""; # Shell script code called during zsh login shell initialisation.
      shellInit = ""; # Shell script code called during zsh shell initialisation.

      setOptions = [
        "HIST_IGNORE_DUPS"
        "SHARE_HISTORY"
        "HIST_FCNTL_LOCK"
        "EXTENDED_HISTORY"
      ];

      ohMyZsh = {
        enable = true;
        theme = "gnzh";
        plugins = [
          "git"
          "sudo"
          "ansible"
          "vagrant"
          "vagrant-prompt"
          "terraform"
          "cp"
          "docker"
          "docker-compose"
          "docker-machine"
          "fzf"
          "man"
          "pj"
          "ripgrep"
          "ssh-agent"
          "zsh-interactive-cd"
          "timer"
        ];
      };

      # An attribute set that maps aliases (the top level attribute names in this option) to command strings or directly to build outputs.
      shellAliases = {
        ll = "ls -alG";
        FZF_BASE = "/path/to/fzf/install/dir";
      };

    };
  };

  ##############################################################################################################################
  ## Service configurations

  services = {
    xrdp = {
      enable = false;
      defaultWindowManager = "startplasma-x11";
    };

    ################################################################################

    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };
  };


  ##############################################################################################################################
  ## System

  system = {
    stateVersion = "22.05"; # Did you read the comment?
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = true;
    autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
  };

  ##############################################################################################################################
  ## nixpkgs

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
    };

    #crossSystem = {   };	# Specifies the platform for which NixOS should be built. Specify this only if it is different from nixpkgs.localSystem …
    #localSystem = {   };	# Specifies the platform on which NixOS should be built. When nixpkgs.crossSystem is unset, it also specifies the platform for which NixOS should be built …
    #pkgs = {   };		# If set, the pkgs argument to all NixOS modules is the value of this option, extended with nixpkgs.overlays, if that is also set.
    #overlays = [   ];		# List of overlays to use with the Nix Packages collection. It allows you to override packages globally.
  };

  ##############################################################################################################################
  ## Nix

  nix = {
    settings = {
      sandbox = true;               # If set, Nix will perform builds in a sandboxed environment that it will set up automatically for each build.
      extra-sandbox-paths = [ ];    # Directories from the host filesystem to be included in the sandbox.
      allowed-users = [ "admin" ];
      trusted-users = [ "root" "@wheel" ];
      trusted-substituters = [ ];   # List of binary cache URLs that non-root users can use (in addition to those specified using nix.binaryCaches)
      require-sigs = true;          # RECOMMENDED!!!
      max-jobs = "auto";            # auto = use all logical cores
      cores = 0;                    # 0 = use all cores
      auto-optimise-store = true;
    };


    nrBuildUsers = 32;

    distributedBuilds = false;
    buildMachines = [ ];

    checkConfig = true;
    daemonIOSchedPriority = 0; # 0 = normal, 7 = lowest

    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
      keep-outputs = true
      keep-derivations = true
    '';

    gc = {
      automatic = true;
      dates = "weekly"; # The format is described in systemd.time
      #options = "";
      persistent = true;
      randomizedDelaySec = "0"; # The format is described in systemd.time
    };

    #nixPath = [   ];

    optimise = {
      automatic = true;
      dates = [ "03:45" ]; # The format is described in systemd.time
    };

    readOnlyStore = true; # RECOMMENDED!!!
    registry = { }; # A system-wide flake registry.

    sshServe = {
      enable = false; # Whether to enable serving the Nix store as a remote store via SSH.
      keys = [ ];
      protocol = "ssh"; # The specific Nix-over-SSH protocol to use: ssh | ssh-ng
    };
  };

  ##############################################################################################################################
  ## Foo

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
    nixos.enable = true;
  };

}
