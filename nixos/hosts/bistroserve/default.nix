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
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = [
      #config.boot.kernelPackages.exfat-nofuse
    ];
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  networking = {
    hostName = "BistroServe";
    hostId = "2a1b5bfb";
    useDHCP =
      false; # global useDHCP flag is deprecated -> explicitly set to false
    interfaces.enp2s0.useDHCP = true;
    wireless.enable = false;

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

  sound.enable = true;

  hardware = { opengl.driSupport32Bit = true; };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  services.xserver = {
    enable = true;
    layout = "de";
    xkbOptions = "eurosign:e";
    libinput.enable =
      true; # Enable touchpad support (enabled default in most desktopManager)

    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  services.pipewire = { enable = true; };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    name = "admin";
    isNormalUser = true;
    isSystemUser = false;
    createHome = true;
    #home = "/home/admin";
    cryptHomeLuks = null;
    shell = pkgs.zsh;
    group = "users";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh = {
      authorizedKeys = {
        keyFiles = [ ];
        keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDprXj7YpJW4JW6EBP8wcWc02Tt1NC/WvRdBcpRnv9zsV3urzrn+Salm3N61rs9DX3sVVZq7JRRHdxLUyIX4QRgwLknqWYO014hKm1hUVoEGRYoH6IdorYXNObmUWjqaN0+j5TGcOUrPEcS42TDmXs6N2onnhKroy3I9j2DTUgDgpR+N9WCGb5u8mXOsG6qPFgBzVfz3bD8v4T6PbYGEg/+UsM0Owc+JZUORAxPcpMg1X+mNdGVVtgAEmpZ9K0eru+rXbgXoTEln4uno8Fg46iGNy/VvMPWvriSMIeqWOL0oHmoXfr/1DCN8/dorpQZ59W3nmcrKd2ml+/2+3R+J/m6HTtNg6eLM7u46E7enqex7mhbJRpnjV9IZF8CWdIaNeJC0Cc1r4QxBuNloIj5rTYqAXVm+0yj/WUS+TCPXxQ2pMmWCILabsmUyLq/YEEcKA57ifMxLEXqM1qDVH6Zbwxph6eKNxFdnP2pHlvnX6cld58iwcUmzFr3HeNKEuCAlAjln0U5K3PieWYA9yh5FHVzvchRRUdKtMLtQdLin13ee9VU+Wx5ZotgvZIdcHCI3Kzz5uemzLcWmEv+RJiWvU65KF1fPTWyA/kQ+pfZ1fd1AMwDA+hx4vmdPubhuUPU5K4RGHXIvuYGP4EbbyTHAQiXlWkffYANeGlTR+3iIEeAZw== mikebrasch@fastmail.fm"
        ];
      };
    };
    packages = [ ];
    pamMount = { };
    subGidRanges = [ ];
    subUidRanges = [ ];
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
    netdata
    bat
    fzf
    fd
    tmux
    kodi
    steam
    firefox
    plasma5Packages.kdeconnect-kde
    elinks

    #node2nix
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
        strategy = "history"; # history | match_prev_cmd
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
      interactiveShellInit =
        ""; # Shell script code called during interactive zsh shell initialisation.
      loginShellInit =
        ""; # Shell script code called during zsh login shell initialisation.
      shellInit =
        ""; # Shell script code called during zsh shell initialisation.

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
    #vscode-server.enable = true;

    xrdp = {
      enable = true;
      defaultWindowManager = "startplasma-x11";
    };

    ################################################################################

    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };

    ################################################################################

    printing = { enable = false; };

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
          browseable =
            "no"; # note: each home will be browseable; the "homes" share will not.
          "read only" = "no";
          "guest ok" = "no";
        };

        "root$" = {
          path = "/";
          writable = "yes";
          "guest ok" = "no";
          #"valid users" = "admin";
          "create mask" =
            "0640"; # Don't give access to world; don't create new files as executable
          "directory mask" = "0750";
          #"force user" = "admin";
          #"force group" = "groupname";
          "map archive" = "no"; # Don't map archive flag to owner's execute bit
          "wide links" =
            "yes"; # Fix issues with accessing symlinks via file dialogs (but not explorer??) on Windows
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
    stateVersion = "20.09"; # Did you read the comment?
    autoUpgrade.enable = false;
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
    allowedUsers = [ "*" ];
    trustedUsers = [ "root" "@wheel" ];
    autoOptimiseStore = true;
    requireSignedBinaryCaches = true; # RECOMMENDED!!!
    trustedBinaryCaches =
      [ ]; # List of binary cache URLs that non-root users can use (in addition to those specified using nix.binaryCaches)
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
    sandboxPaths =
      [ ]; # Directories from the host filesystem to be included in the sandbox.

    sshServe = {
      enable =
        false; # Whether to enable serving the Nix store as a remote store via SSH.
      keys = [ ];
      protocol =
        "ssh"; # The specific Nix-over-SSH protocol to use: ssh | ssh-ng
    };

    #systemFeatures = [   ];		# The supported features of a machine.
    useSandbox =
      true; # If set, Nix will perform builds in a sandboxed environment that it will set up automatically for each build.
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  documentation = {
    enable = true;
    dev.enable = false;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
    nixos.enable = true;
  };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  # NAT forwarding

  #networking.nat.enable = true;
  #networking.nat.internalInterfaces = [ "ve-munki" ];   # use "ve-*" to let all virtual interfaces tot the internet
  #networking.nat.externalInterface = "eth0";

  # reverse proxy

  # security.acme.acceptTerms = true;
  # security.acme.email = "bistromath@fastmail.fm";

  #  services.nginx = {
  #    enable = true;
  #    recommendedProxySettings = true;
  #    recommendedTlsSettings = true;
  #    recommendedOptimisation = true;
  #    recommendedGzipSettings = true;

  #    virtualHosts = {
  #      "munki.local" = {
  #       enableACME = false;
  #       forceSSL = false;
  #       locations."/".proxyPass = "http://10.192.168.241:80";
  #      };
  #    };
  #  };

  # containers

  #   containers.munki = {
  #     ephemeral = false;
  #     autoStart = true;
  #     #dropCapabilities = ???;
  #
  #     privateNetwork = true;       # implicit create a virtual interface and decouple from host
  #     hostAddress = "10.192.168.231";
  #     localAddress = "10.192.168.241";
  #     forwardPorts = [ { protocol = "tcp"; hostPort = 8080; containerPort = 80; } ];
  #
  #     config = { config, pkgs, ... }: {
  #       services.nginx.enable = true;
  #       #services.nginx.adminAddr = "foo@example.org";
  #       networking.firewall.allowedTCPPorts = [ 80 ];
  #       #systemd.tmpfiles.rules = [
  #       #  "d /var/log/nginx 700 wwwrun wwwrun -"
  #       #];
  #     };
  #
  #     #bindMounts = {
  #     #  "/var/log/nginx" = {
  #     #    hostPath = "/mnt/munkiData/";
  #     #    isReadOnly = false;
  #     #  };
  #     #};
  #   };

  ##############################################################################################################################
  ##############################################################################################################################
  ##############################################################################################################################

  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  # };

  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers = {
  #nextcloud = { ########################################################################################
  #  image = "nextcloud:20.0.4";
  #  extraOptions = [
  #    "--ip=10.192.168.50"
  #    "--add-host=db:10.192.168.51"
  #  ];
  #  volumes = [
  #    "/data/nextcloud/docroot:/var/www/html"
  #  ];
  #  environment = {
  #    POSTGRES_HOST = "db";
  #    POSTGRES_PORT = "5432";
  #    POSTGRES_DB = "nextcloud";
  #    POSTGRES_USER = "";
  #    POSTGRES_PASSWORD = "";
  #    TRUSTED_PROXIES = "10.88.10.10";
  #    NEXTCLOUD_ADMIN_USER = "admin";
  #    NEXTCLOUD_TRUSTED_DOMAINS = "<domain> 10.192.168.*";
  #    NEXTCLOUD_ADMIN_PASSWORD = "";
  #    OBJECTSTORE_S3_HOST = "s3.us-west-001.backblazeb2.com";
  #    OBJECTSTORE_S3_BUCKET = "this-bucket-does-not-exist";
  #    OBJECTSTORE_S3_KEY = "";
  #    OBJECTSTORE_S3_SECRET = "";
  #    OBJECTSTORE_S3_PORT = "443";
  #    OBJECTSTORE_S3_SSL = "true";
  #    OBJECTSTORE_S3_REGION = "us-west-001";
  #    OBJECTSTORE_S3_USEPATH_STYLE = "false";
  #  };
  #};

  #db = { ########################################################################################
  #  image = "postgres:13.1";
  #  extraOptions = [
  #    "--ip=10.88.10.13"
  #  ];
  #  environment = {
  #    POSTGRES_DB = "postgres";
  #    POSTGRES_USER = "root";
  #    POSTGRES_PASSWORD = "";
  #  };
  #  volumes = [
  #    "/data/db/postgres:/var/lib/postgresql/data/"
  #  ];
  #};
  #   };
  # };

}
