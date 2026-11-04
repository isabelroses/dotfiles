{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.garden.services;

  # an attrset filter makes the module write filter.d/<jail name>.conf
  vaultwardenJail = failregex: {
    filter.Definition = {
      inherit failregex;
      ignoreregex = "";
    };
    settings = {
      journalmatch = "_SYSTEMD_UNIT=vaultwarden.service";
      port = "http,https";
      # quic is on, so a tcp-only ban leaves http/3 open
      protocol = "tcp,udp";
      maxretry = 3;
      bantime = 14400;
      findtime = 14400;
    };
  };
in
{
  services.fail2ban = {
    enable = true;
    maxretry = 7;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
      # the tailnet
      "100.64.0.0/10"
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

      (mkIf cfg.mailserver.enable {
        postfix.settings = {
          mode = "aggressive";
          port = "smtp,465,submission";
        };

        dovecot.settings = {
          mode = "aggressive";
          port = "pop3,pop3s,imap,imaps,submission,465,sieve";
        };
      })

      # clients that keep getting rate limited, mostly scrapers
      (mkIf config.services.nginx.enable {
        nginx-limit-req.settings = {
          port = "http,https";
          protocol = "tcp,udp";
        };
      })

      # https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup
      (mkIf cfg.vaultwarden.enable {
        vaultwarden = vaultwardenJail ''^.*?Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$'';
        vaultwarden-admin = vaultwardenJail ''^.*?Invalid admin token\. IP: <ADDR>.*$'';
      })
    ];
  };
}
