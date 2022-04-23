{
  description = "Mike's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos.url = "github:nixos/nixpkgs/nixos-21.11";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-utils.url = "github:numtide/flake-utils";
    nixos-shell.url = "github:Mic92/nixos-shell";

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, darwin, home-manager, nixos-generators, nur, flake-utils, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs.lib) attrValues makeOverridable optionalAttrs singleton;

      systems = [ "x86_64-darwin" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      nixpkgsConfig = with inputs; rec {
        config = { allowUnfree = true; };
      };

      mkVM = import ./lib/mkvm.nix;

      # Home Manager configuration shared between all different configurations.
      homeManagerStateVersion = "22.05";
      homeManagerCommonConfig = { user, userConfig ? ./home + "/users/${user}.nix", ... }: {
        imports = attrValues self.homeManagerModules ++ [
          userConfig
          ./home
          { home.stateVersion = homeManagerStateVersion; }
        ];
      };

      nixDarwinCommonModules = args@{ user, host, hostConfig ? ./darwin/hosts + "/${host}.nix", ... }: [
        home-manager.darwinModules.home-manager
        ./darwin
        hostConfig rec {
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
        bootstrap-darwin = makeOverridable darwinSystem {
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
        # githubActions = darwinSystem {
        #   system = "x86_64-darwin";
        #   modules = nixDarwinCommonModules {
        #     user = "runner";
        #     host = "github-actions";
        #   };
        # };
      };

      # ----------------------------------------------------------------------------------------------------

      nixosConfigurations = {
        # minimal configuration
        bootstrap-nixos = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          stateVersion = homeManagerStateVersion;
          homeDirectory = "/home/admin";
          username = "admin";
          configuration = {
            imports = [ (homeManagerCommonConfig { user = "admin"; }) ];
            nixpkgs = nixpkgsConfig;
          };
        };

        # configuration for homeserver
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

        nixos-vm = nixos-generators.nixosGenerate {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./nixos/hosts/nixos-vm/configuration.nix
          ];
          format = "vmware";
        };
      };

      # ----------------------------------------------------------------------------------------------------

      darwinModules = { };

      homeManagerModules = {
        #awscli = import ./home/modules/programs/awscli.nix;
      };

      # `nix develop`
      devShell = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ rnix-lsp nixpkgs-fmt ];
        });
    };
}
