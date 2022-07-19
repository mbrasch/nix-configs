{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    #./nixos/modules/services/web-servers/munki.nix
    #(fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master")
    #(fetchTarball "https://github.com/erlingal/nix-homebridge/tarball/master")
  ];

  boot = {
    loader = {
      grub.enable = true;
      grub.version = 2;
      grub.device = "/dev/sda";
    };

    kernelParams = [
      "console=ttyS0,115200"
      "console=tty1"
    ];

    kernelPackages = [
      pkgs.zfsUnstable.latestCompatibleLinuxPackages
    ];

    extraModulePackages = [
      #config.boot.kernelPackages.exfat-nofuse
    ];
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand"; # "ondemand", "powersave", "performance"
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  networking = {
    hostName = "BistroServe";
    hostId = "2a1b5bfb";
    interfaces.enp1s0.useDHCP = true;
    interfaces.enp1s0.wakeOnLan.enable = true;
    interfaces.enp2s0.useDHCP = true;
    interfaces.enp3s0.useDHCP = true;
    interfaces.enp4s0.useDHCP = true;

    #proxy = {
    #  enable = false;
    #  default = "http://user:password@proxy:port/";
    #  noProxy = "127.0.0.1,localhost,internal.domain";
    #};

    firewall = {
      enable = false;
      allowedTCPPorts = [ 80 ];
      allowedUDPPorts = [ ];
    };
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  # Select internationalisation properties.
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

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
  ##############################################################################################################################
  ##############################################################################################################################

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
  ##############################################################################################################################
  ##############################################################################################################################

  # Some programs need SUID wrappers, can be configured further or are started in user sessions.

  programs = {
    mtr.enable = true;

    gnupg.agent = {
      enable = false;
      enableSSHSupport = true;
    };

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
        strategy = [ "completion" ]; # history | completion | match_prev_cmd
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
  ##############################################################################################################################
  ##############################################################################################################################

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

    ################################################################################

    printing.enable = false;

    ################################################################################

    samba = {
      enable = true;
      enableNmbd = false;
      enableWinbindd = false;
      #securityType = "user";
      extraConfig = ''
        browseable = yes
        #smb encrypt = required
        client min protocol = SMB3_11
        #allow insecure wide links = yes             # We don't need this checking because we have just one share that exports /
        #hosts allow = 10.192.168.0/8 localhost
        #hosts deny = 0.0.0.0/0
        #guest account = nobody
        #map to guest = bad user

        # Settings for macOS clients to store resource forks in xattrs and to fix other issues
        # Based on https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
        # https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html
        vfs objects = fruit streams_xattr
        fruit:metadata = stream
        fruit:model = MacSamba
        fruit:posix_rename = yes
        fruit:veto_appledouble = no
        fruit:wipe_intentionally_left_blank_rfork = yes
        fruit:delete_empty_adfiles = yes
      '';

      shares = {
        homes = {
          browseable =  "no"; # note: each home will be browseable; the "homes" share will not.
          "read only" = "no";
          "guest ok" = "no";
        };

        "root$" = {
          path = "/";
          writable = "yes";
          "guest ok" = "no";
          #"valid users" = "admin";
          "create mask" = "0640"; # Don't give access to world; don't create new files as executable
          "directory mask" = "0750";
          #"force user" = "admin";
          #"force group" = "groupname";
          "map archive" = "no"; # Don't map archive flag to owner's execute bit
          "wide links" = "yes"; # Fix issues with accessing symlinks via file dialogs (but not explorer??) on Windows
        };

        #media = {
        #  path = "/volumes/Media";
        #  browseable = "yes";
        #  writable = "no";
        #  "guest ok" = "yes";
        #  "valid users" = "admin";
        #  "create mask" = "0640";
        #  "directory mask" = "0750";
        #  #"force user" = "admin";
        #  #"force group" = "groupname";
        #  "map archive" = "no";               # Don't map archive flag to owner's execute bit
        #  "wide links" = "yes";               # Fix issues with accessing symlinks via file dialogs (but not explorer??) on Windows
        #};

      };
    };

    ################################################################################

    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';
      };
    };
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  system = {
    stateVersion = "21.11"; # Did you read the comment?
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = true;
    autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

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
  ##############################################################################################################################
  ##############################################################################################################################

  nix = {
    allowedUsers = [ "admin" ];
    trustedUsers = [ "root" "@wheel" ];
    autoOptimiseStore = true;
    requireSignedBinaryCaches = true; # RECOMMENDED!!!
    trustedBinaryCaches = [ ]; # List of binary cache URLs that non-root users can use (in addition to those specified using nix.binaryCaches)
    #binaryCachePublicKeys = [   ];
    #binaryCaches = [   ];
    buildCores = 0; # 0 = use all cores
    maxJobs = "auto"; # auto = use all logical cores
    nrBuildUsers = 32;

    distributedBuilds = false;
    buildMachines = [ ];

    checkConfig = true;
    daemonIOSchedPriority = 0; # 0 = normal, 7 = lowest
    #daemonNiceLevel = 0;		# 0 = normal, 19 = lowest
    #envVars = {   };

    package = pkgs.nixFlakes;

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
    sandboxPaths = [ ]; # Directories from the host filesystem to be included in the sandbox.

    sshServe = {
      enable = false; # Whether to enable serving the Nix store as a remote store via SSH.
      keys = [ ];
      protocol = "ssh"; # The specific Nix-over-SSH protocol to use: ssh | ssh-ng
    };

    #systemFeatures = [   ];		# The supported features of a machine.
    useSandbox = true; # If set, Nix will perform builds in a sandboxed environment that it will set up automatically for each build.
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
    nixos.enable = true;
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

}
