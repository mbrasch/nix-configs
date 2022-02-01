{
  description = "Mike's dotfiles";

  inputs = {
    #nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    #nixos-stable.url = "github:nixos/nixpkgs/nixos-21.11";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    #nur.url = "github:nix-community/NUR";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { self, nixpkgs, darwin, home-manager, nur, flake-utils, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib)
        attrValues makeOverridable optionalAttrs singleton;

      systems = [ "x86_64-darwin" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      nixpkgssConfig = with inputs; rec {
        config = { allowUnfree = true; };
        overlays = self.overlays;
      };

      # Home Manager configuration shared between all different configurations.
      homeManagerStateVersion = "22.05";
      homeManagerCommonConfig =
        { user, userConfig ? ./home + "/users/${user}.nix", ... }: {
          imports = attrValues self.homeManagerModules ++ [
            userConfig
            ./home
            { home.stateVersion = homeManagerStateVersion; }
          ];
        };

      nixDarwinCommonModules = args@{ user, host
        , hostConfig ? ./darwin/hosts + "/${host}.nix", ... }: [
          home-manager.darwinModules.home-manager
          ./darwin
          hostConfig
          rec {
            nixpkgs = nixpkgsConfig;
            users.users.${user}.home = "/Users/${user}";
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.users.${user} = homeManagerCommonConfig args;
          }
        ];

    in {

      # ----------------------------------------------------------------------------------------------------

      darwinConfigurations = {

        # Minimal configuration to bootstrap darwin systems
        bootstrap = makeOverridable darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsConfig; } ];
        };

        # My primary macOS configuration
        mbrasch = darwinSystem {
          system = "x86_64-darwin";
          modules = nixDarwinCommonModules {
            user = "mbrasch";
            host = "mbrasch";
          };
        };

        # Configuration used for CI with GitHub actions
        githubActions = darwinSystem {
          system = "x86_64-darwin";
          modules = nixDarwinCommonModules {
            user = "runner";
            host = "github-actions";
          };
        };
      };

      # ----------------------------------------------------------------------------------------------------

      nixosConfigurations = {
        bistroserve = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          stateVersion = homeManagerStateVersion;
          homeDirectory = "/home/admin";
          username = "admin";
          configuration = {
            imports = [ (homeManagerCommonConfig { user = "admin"; }) ];
            nixpkgs = nixpkgsConfig;
          };
        };

        # nixos-vm = mkVM "vm-intel" rec {
        #   inherit nixpkgs home-manager overlays;
        #   system = "x86_64-linux";
        #   user = "admin";
        # };
      };

      # ----------------------------------------------------------------------------------------------------

      darwinModules = { };

      homeManagerModules = {
        awscli = import ./modules/home/programs/awscli.nix;
      };

      overlays = let path = ./overlays;
      in with builtins;
      map (n: import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n != null
        || pathExists (path + ("/" + n + "/default.nix")))
        (attrNames (readDir path)));

      # `nix develop`
      devShell = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ rnix-lsp nixpkgs-fmt ];
        });
    };
}
