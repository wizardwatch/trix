/*nixosModule = */{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.trix.services.minecraft;
in 
{
    options.trix.services.minecraft = {
      enable = mkEnableOption "Enables the packwiz minecraft service";
    };
    config = mkIf cfg.enable {
      users.users.minecraft = {
        description     = "Minecraft server service user";
        isSystemUser    = true;
        group           = "minecraft";
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
        WorkingDirectory = /etc/minecraft;
      };
    };
 };
}
