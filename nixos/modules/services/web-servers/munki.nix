{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.munki;

in {

  #####################################################################################################
  #####################################################################################################
  #####################################################################################################

  options.services.munki = {

  };

  #####################################################################################################
  #####################################################################################################
  #####################################################################################################

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      uid = config.ids.uids.${cfg.user};
      description = "munki user";
      home = stateDir;
      group = ${cfg.group};
    };

    users.group.${cfg.group} = {
      uid = config.ids.uids.${cfg.user};
      description = "munki group";
    };

    systemd.services.micromdm = {
      description = ''Munki, Managed software installation for OS X.'';
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        mkdir -p ${stateDir}
        chown ${virtuosoUser} ${stateDir}
      '';

      script = ''
        ${pkgs.munki}/bin/munki serve -server-url=${cfg.serverUrl} -api-key=${cfg.apiKey} -filerepo ${cfg.fileRepo}
      '';
    };

  };

}
