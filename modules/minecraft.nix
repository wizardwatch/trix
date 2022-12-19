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
        ${cfg.dataDir}/start.sh
        '';
        WorkingDirectory = cfg.dataDir;
      };
    };
      system.activationScripts.minecraft-server-data-dir.text = ''
          mkdir -p ${cfg.dataDir}
          rm ${cfg.dataDir}/start.sh
          touch ${cfg.dataDir}/start.sh
          echo "#!/bin/sh
wget -nc -q -O "/srv/minecraft/server.jar" "https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar"
wget -nc -q -O "/srv/minecraft/packwiz-installer-bootstrap.jar" "https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
java -jar /srv/minecraft/packwiz-installer-boostrap.jar
java -Xmx6G -jar /srv/minecraft/fabric-server-launch.jar nogui" >> ${cfg.dataDir}/start.sh
          chown minecraft:minecraft ${cfg.dataDir}
          chmod -R 775 ${cfg.dataDir}
      '';
 };
}
