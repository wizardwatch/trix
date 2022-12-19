/*nixosModule = */{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.trix.services.minecraft;
in 
{
    options.trix.services.minecraft = {
      enable = mkEnableOption "Enables the packwiz minecraft service";
      dataDir = mkOption rec { 
        type = types.path;
        default =  "/srv/minecraft";
        example = default;
        description = "the path stuff is kept at";
      };
    };
    config = mkIf cfg.enable {
      users.users.minecraft = {
        description     = "Minecraft server service user";
        isSystemUser    = true;
        group           = "minecraft";
        home            = cfg.dataDir;
      };
      users.groups.minecraft = {};
      systemd.services.minecraft = {
        wantedBy = [ "default.target" ];
        after = [ "network.target" ];
        description = "start minecraft";
        serviceConfig = {
        Type = "simple";
        User = "wyatt";
        RestartSec = "10s";
        Restart = "always";
        StandardError= "journal";

        # run the start script for the specified server
        ExecStart = ''
        /usr/bin/env bash $(wget https://raw.githubusercontent.com/wizardwatch/winter-wonderland-pack/main/start.sh) 
        '';
        WorkingDirectory = cfg.dataDir;
      };
      system.activationScripts.minecraft-server-data-dir.text = ''
          mkdir -p ${cfg.dataDir}
          chown minecraft:minecraft ${cfg.dataDir}
          chmod -R 775 ${cfg.dataDir}
      '';
    };
 };
}
