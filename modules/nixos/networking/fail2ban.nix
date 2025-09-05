{ lib, config, ... }:
let
  inherit (lib) mkIf mkMerge;

  cfg = config.garden.services;
in
{
  services.fail2ban = {
    enable = true;
    banaction = "iptables-multiport[blocktype=DROP]";
    maxretry = 7;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
    ];

    bantime-increment = {
      enable = true;
      rndtime = "12m";
      overalljails = true;
      multipliers = "4 8 16 32 64 128 256 512 1024 2048";
      maxtime = "192h";
    };

    jails = mkMerge [
      {
        sshd.settings.mode = "aggressive";
      }

      # vaultwarden and vaultwarden admin interface jails
      (mkIf cfg.vaultwarden.enable {
        vaultwarden = {
          filter = "vaultwarden";
          settings = {
            port = "80,443,${toString cfg.vaultwarden.port}";
            banaction = "%(banaction_allports)s";
            logpath = "/var/log/vaultwarden.log";
            maxretry = 3;
            bantime = 14400;
            findtime = 14400;
          };
        };

        vaultwarden-admin = {
          filter = "vaultwarden-admin";
          settings = {
            port = "80,443,${toString cfg.vaultwarden.port}";
            banaction = "%(banaction_allports)s";
            logpath = "/var/log/vaultwarden.log";
            maxretry = 3;
            bantime = 14400;
            findtime = 14400;
          };
        };
      })
    ];
  };
}
