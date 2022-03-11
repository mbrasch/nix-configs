# This file contains configuration that is shared across all hosts.

{ pkgs, lib, options, ... }: {
  nix = {
    package = pkgs.nixVersions.unstable; # war: nixFlakes
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

  programs = {
    zsh = {
      enable = true;
      promptInit = "";
    };
  };

}
