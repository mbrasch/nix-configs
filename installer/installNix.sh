#!/bin/bash

yes | sh <(curl -L https://nixos.org/nix/install) --daemon"

sudo echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf

nix build .#darwinConfigurations.bootstrap.system
./result/sw/bin/darwin-rebuild switch --flake .#bootstrap






    pressENTERorCTRLC
  else
    sudo launchctl load -w /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    sudo launchctl enable /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    echo -e " | installation failed. If the messages above tell something about \"Service is disabled\""
    echo -e " | then it should still run, as I've pro-actively started the daemon afterwards:"
    sudo launchctl list | grep nix-daemon
    #exit 1
  fi
else
  echo -e " | nix is aleady installed."
fi


if [ "$(nix-shell -p nix-info --run "nix-info -m")" ]; then
  echo -e "\n==> Test was successful.";
else
  echo -e "Test was not successful. We have to abort here. There is nothig I can do. :(";
  exit 1
fi
