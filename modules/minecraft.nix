/*nixosModule = */{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.trix.services.minecraft;
  jre_headless = pkgs.openjdk17;
  wget = pkgs.wget;
  bash = pkgs.bash;
  sha1 = pkgs.sha1collisiondetection;
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
      networking.firewall.allowedTCPPorts = [ 25565 ];
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
        User = "minecraft";
        RestartSec = "10s";
        Restart = "always";
        StandardError= "journal";
        path = [pkgs.bash pkgs.openjdk17 pkgs.wget pkgs.sha1collisiondetection];
        # run the start script for the specified server
        ExecStart = ''
        ${bash}/bin/bash ${cfg.dataDir}/start.sh
        '';
        WorkingDirectory = cfg.dataDir;
      };
    };
      system.activationScripts.minecraft-server-data-dir.text = ''
          mkdir -p ${cfg.dataDir}
          rm ${cfg.dataDir}/start.sh
          touch ${cfg.dataDir}/start.sh
          echo "#!/bin/sh
echo "${sha1}"
${wget}/bin/wget -nc -O "/srv/minecraft/server.jar" "https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar"
${wget}/bin/wget -nc -O "/srv/minecraft/packwiz-installer-bootstrap.jar" "https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
chmod +x /srv/minecraft/packwiz-installer-bootstrap.jar
chmod +x /srv/minecraft/fabric-server-launch.jar 
${jre_headless}/bin/java -jar /srv/minecraft/packwiz-installer-bootstrap.jar
${jre_headless}/bin/java -Xmx6G -jar /srv/minecraft/fabric-server-launch.jar nogui" >> ${cfg.dataDir}/start.sh
chmod +x ${cfg.dataDir}
          chown minecraft:minecraft ${cfg.dataDir}
          chmod -R 775 ${cfg.dataDir}
      '';
 };
}
