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
        RestartSec = "60s";
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
${wget}/bin/wget -nc -O "/srv/minecraft/server_quilt.jar" "https://maven.quiltmc.org/repository/release/org/quiltmc/quilt-installer/latest/quilt-installer-latest.jar"
${wget}/bin/wget -nc -O "/srv/minecraft/packwiz-installer-bootstrap.jar" "https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
chmod +x /srv/minecraft/packwiz-installer-bootstrap.jar
chmod +x /srv/minecraft/fabric-server-launch.jar 
${jre_headless}/bin/java -jar /srv/minecraft/packwiz-installer-bootstrap.jar -g -s server https://ryleu.me/winter-wonderland-pack/main/pack.toml
${jre_headless}/bin/java -Xmx4096m -jar server_quilt.jar nogui" >> ${cfg.dataDir}/start.sh
chmod +x ${cfg.dataDir}
          chown minecraft:minecraft ${cfg.dataDir}
          chmod -R 775 ${cfg.dataDir}
      '';
 };
}
