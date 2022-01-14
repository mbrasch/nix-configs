sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume --daemon

source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export NIX_PATH=darwin-config=$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
#source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
bash
nix-shell '<home-manager>' -A install
home-manager switch
nix-shell '<darwin>' -A installer
darwin-rebuild switch
