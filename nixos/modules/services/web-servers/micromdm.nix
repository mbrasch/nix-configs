{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.micromdm;

in {

  #####################################################################################################
  #####################################################################################################
  #####################################################################################################

  options.services.micromdm = {
    enable = mkEnableOption "Enable MicroMDM";

    serverUrl = mkOption {
      type = with types; nullOr str;
      default = "http://localhost";
      example = '''';
      description = ''serverUrl MUST be the https:// URL you (and your devices) will use to connect to MicroMDM.'';
    };

    apiKey = mkOption {
      type = types.str;
      default = "";
      example = '''';
      description = ''
        apiKey is a secret you MUST create to protect the API. It will be used to authenticate API requests both
        from your own integrations, as well as mdmdctl.
      '';
    };

    fileRepo = mkOption {
      type = with types; nullOr path;  # types.nullOr types.path;
      default = "";
      example = '''';
      description = ''
        fileRepo is an optional key which needs to point to a directory micromdm can read and write to.
        It is used for packages uploaded by mdmctl apply app. It is not necessary if you do not intend
        to push custom packages via InstallApplication commands.
      '';
    };

    tlsCert = mkOption {
      type = types.path;
      default = "";
      example = '''';
      description = '''';
    };

    tlsKey = mkOption {
      type = types.path;
      default = "";
      example = '''';
      description = '''';
    };

    user = mkOption {
        type = types.str;
        default = "micromdm";
        description = "User account under which MicroMDM runs.";
      };

    group = mkOption {
      type = types.str;
      default = "micromdm";
      description = "Group under which MicroMDM runs.";
    };
  };

  #####################################################################################################
  #####################################################################################################
  #####################################################################################################

  config = mkIf cfg.enable {

    users.users.${cfg.user} = {
      uid = config.ids.uids.micromdm;
      description = "micromdm user";
      home = stateDir;
      group = ${cfg.group};
    };

    users.group.${cfg.group} = {
      uid = config.ids.uids.micromdm;
      description = "micromdm group";
    };

    systemd.services.micromdm = {
      description = ''MicroMDM, the Mobile Device Management for macOS clients.'';
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        mkdir -p ${stateDir}
        chown ${virtuosoUser} ${stateDir}
      '';

      script = ''
        ${pkgs.micromdm}/bin/micromdm serve -server-url=${cfg.serverUrl} -api-key=${cfg.apiKey} -filerepo ${cfg.fileRepo}
      '';
    };

  };
};
