{ config, pkgs, lib, ... }:
let
  tmp_directory = "/tmp";
  home_directory = "${config.home.homeDirectory}";
in rec {
  imports = [ ./shells.nix ];

  home = {
    sessionVariables = {
      EDITOR = "${pkgs.nano}/bin/nano";
      #EMAIL = "${config.programs.git.userEmail}";
      PAGER = "${pkgs.less}/bin/less";
      CLICOLOR = true;
      GPG_TTY = "$TTY";
      #PATH = "$PATH:$HOME/.local/bin:$HOME/.tfenv/bin";
    };

    packages = with pkgs; [
      ##### Nix stuff #####

      nix-top # Tracks what nix is building
      nix-du # A tool to determine which gc-roots take space in your nix store   –>   build error: No such file or directory (os error 2)
      nix-diff # Explain why two Nix derivations differ
      #nix-index                       # A files database for nixpkgs
      nix-tree # Interactively browse a Nix store paths dependencies
      nix-bundle # Create bundles from Nixpkgs attributes
      nix-linter # Linter for Nix(pkgs), based on hnix   –>   build error: Encountered missing or private dependencies: hnix ==0.6.*
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
      nix-review # Review pull-requests on https://github.com/NixOS/nixpkgs
      #nix-serve                      # A utility for sharing a Nix store as a binary cache
      nixfmt # An opinionated formatter for Nix
      nixbang # A special shebang to run scripts in a nix-shell
      #vulnix # NixOS vulnerability scanner
      #nix-doc
      nix-template

      #disnix                         # A Nix-based distributed service deployment tool
      #disnixos                       # Provides complementary NixOS infrastructure deployment to Disnix
      #dysnomia                       # Automated deployment of mutable components and services for Disnix

      #nixops                         # NixOS cloud provisioning and deployment tool
      #nixops-dns                     # DNS server for resolving NixOps machines
      morph
      lorri # Your project's nix-env
      niv # Easy dependency management for Nix projects

      nixpkgs-lint # A utility for Nixpkgs contributors to check Nixpkgs for common errors
      nixpkgs-fmt # Nix code formatter for nixpkgs
      nixpkgs-review # Review pull-requests on https://github.com/NixOS/nixpkgs

      ##### containerization stuff #####

      #docker                          # An open source project to pack, ship and run any application as a lightweight container
      #docker-compose                  # Multi-container orchestration for Docker
      #docker-machine                  # Docker Machine is a tool that lets you install Docker Engine on virtual hosts, and manage Docker Engine on the hosts
      #linuxkit                        # A toolkit for building secure, portable and lean operating systems for containers
      ansible # Radically simple IT automation
      #ansible-lint                    # Best practices checker for Ansible
      vagrant # A tool for building complete development environments
      #terraform                       # Tool for building, changing, and versioning infrastructure
      #packer                          # A tool for creating identical machine images for multiple platforms from a single source configuration
      #hashi-ui                       # A modern user interface for hashicorp Consul & Nomad
      #nomad                           # A Distributed, Highly Available, Datacenter-Aware Scheduler
      #consul                          # Tool for service discovery, monitoring and configuration
      #mkpasswd                       # unsopported system

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
      antibody # shell plugin manager
      mosh # mobile shell
      shellcheck
      #fish

      ###### services stuff ######

      davmail
      netdata

      ##### modern alternatives to old tools #####

      fd # find
      bat # cat
      exa # ls
      procs # ps
      sd # sed
      #dust                           # du   ->   runtime error: -jit/bin/pixie-vm: No such file or directory
      ripgrep # grep
      hyperfine # benchmarking (-> time)

      ##### network stuff #####

      #sshfs
      openssh
      #telnet
      mtr # A network diagnostics tool
      nmap # A free and open source utility for network discovery and security auditing
      ncat # A free and open source utility for network discovery and security auditing
      #ntopng                         # High-speed web-based traffic analysis and flow collection tool   –>   build error: comparison between pointer and integer ('char *' and 'char')
      #nethogs                        # A small 'net top' tool, grouping bandwidth by process (not darwin)
      #nload                          # Monitors network traffic and bandwidth usage with ncurses graphs   –>   linux only
      iperf # Tool to measure IP bandwidth using UDP or TCP
      #slurm                          # Simple Linux Utility for Resource Management   –>   linux only
      #iproute                        # A collection of utilities for controlling TCP/IP networking and traffic control in Linux   –>   linux only
      iftop # Display bandwidth usage on a network interface
      dnstop # libpcap application that displays DNS traffic on your network
      dnsperf # Tools for DNS benchmaring
      #gotop                           # A terminal based graphical activity monitor inspired by gtop and vtop
      coreutils				              # The basic file, shell and text manipulation utilities of the GNU operating system
      #ocrmypdf                        # Adds an OCR text layer to scanned PDF files, allowing them to be searched   –>   "Unsupported OS"
      #thefuck                        # Magnificent app which correct your previous console command
      #ngrep                          # Network packet analyzer -> Linux only
      mitmproxy # Man-in-the-middle proxy
      #p0f                            # Passive network reconnaissance and fingerprinting tool   –>   failed with exit code 2;
      #endlessh                       # SSH tarpit that slowly sends an endless banner
      #duplicati                      # A free backup client that securely stores encrypted, incremental, compressed backups on cloud storage services and remote file servers
      wireguard # Tools for the WireGuard secure network tunnel
      #wireguard-go                   # Userspace Go implementation of WireGuard
      #boringtun                      # Userspace WireGuard® implementation in Rust
      wireguard-tools # Tools for the WireGuard secure network tunnel
      #gogs					                  # A painless self-hosted Git service
      #magic-wormhole                 # Securely transfer data between computers
      #croc                           # Securely transfer data between computers
      tmux

      ###### language stuff ######

      autoconf
      go
      #(lua.withPackages (p: with p; [ luarocks mpack ]))

      #---
      (python3.withPackages (p: with p; [ pip jinja2 protobuf passlib ]))
      #python39Packages.adb-homeassistant # A pure python implementation of the Android ADB and Fastboot protocols

      #---

      php74
      php74Extensions.mbstring
      php74Extensions.json

      #---

      perl
      perlPackages.IO

      #---

      #(ruby.withPackages (p: with p; [ cocoapods ]))
      bundix # package your Bundler-enabled Ruby applications with the Nix package manager.
      adoptopenjdk-openj9-bin-11
      #jetbrains.idea-community
      #android-tools                  # -> does not build -> install via brew

      ###### desktop software stuff #####
      #mediathekview

      ###### other stuff ######

      #starship                       # shell prompt
      tokei # statistic over code
      tealdeer # tldr
      bandwhich # network utilization by process
      grex # A command-line tool for generating regular expressions from user-provided test cases
      #nutshell                       # modern shell
      lastpass-cli # Stores, retrieves, generates, and synchronizes passwords securely
      git
      #git-town                       # Generic, high-level git support for git-flow workflows
      file # A program that shows the type of files
      htop # An interactive process viewer
      ffmpeg # A complete, cross-platform solution to record, convert and stream audio and video
      flvstreamer # Command-line RTMP client
      tesseract4 # OCR engine
      yt-dlp # Command-line tool to download videos from YouTube.com and other sites
      #coursera-dl                     # CLI for downloading Coursera.org videos and naming them
      gallery-dl # CLI program to download image-galleries and -collections from several image hosting sites
      pandoc # Conversion between markup formats
      graphviz

      python39Packages.pyfritzhome
    ];
  };

  programs = {

    home-manager = { enable = true; };

    # awscli = {
    #   package = pkgs.awscli2;
    #   enable = false;
    #   enableBashIntegration = true;
    #   enableZshIntegration = true;
    #   awsVault = {
    #     enable = true;
    #     prompt = "ykman";
    #     backend = "pass";
    #     passPrefix = "aws_vault/";
    #   };
    # };

    # browserpass = {
    #   enable = false;
    #   browsers = [ "firefox" ];
    # };

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

    go.enable = true;

    #     ssh = {
    #       enable = true;
    #
    #       controlMaster = "auto";
    #       controlPath = "${tmp_directory}/ssh-%u-%r@%h:%p";
    #       controlPersist = "1800";
    #
    #       forwardAgent = true;
    #       serverAliveInterval = 60;
    #
    #       hashKnownHosts = true;
    #
    #       extraConfig = ''
    #         #SCE_GROUP:B0713CB6-A009-4E72-AC09-A9DE823B9F60:::Privat
    #
    #         Host BistroServe
    #           User admin
    #           HostName bistroserve
    #           IdentityFile ~/.ssh/private.id.rsa
    #           #SCEIcon home
    #           #SCEGroup B0713CB6-A009-4E72-AC09-A9DE823B9F60
    #
    #         #SCE_GROUP:D34811CE-4F87-4B7F-AFAE-826B9310D5AF:::Serviceware
    #
    #         Host bc-climgmt3.pmcs.de
    #           User mbrasch
    #           IdentityFile ~/.ssh/serviceware.id.rsa
    #           #SCEIcon suitcase
    #           #SCEGroup D34811CE-4F87-4B7F-AFAE-826B9310D5AF
    #       '';
    #     };
  };

  #   xdg = {
  #     enable = true;
  #
  #     configHome = "${home_directory}/.config";
  #     dataHome = "${home_directory}/.local/share";
  #     cacheHome = "${home_directory}/.cache";
  #   };
}
