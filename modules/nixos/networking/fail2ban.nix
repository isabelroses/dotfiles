{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.strings) concatStringsSep;

  cfg = config.garden.services;

  # quic is on, so a tcp-only ban leaves http/3 open
  web = {
    port = "http,https";
    protocol = "tcp,udp";
  };

  # nginx's access log goes to a file rather than the journal
  accessLog = web // {
    backend = "auto";
    logpath = "/var/log/nginx/access.log";
  };

  # fail2ban only reads extra regexes from indented continuation lines
  journalJail = unit: regexes: settings: {
    filter.Definition = {
      failregex = concatStringsSep "\n    " regexes;
      ignoreregex = "";
    };
    settings = web // { journalmatch = "_SYSTEMD_UNIT=${unit}.service"; } // settings;
  };

  vaultwardenJail =
    failregex:
    journalJail "vaultwarden" [ failregex ] {
      maxretry = 3;
      bantime = 14400;
      findtime = 14400;
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

      (mkIf config.services.nginx.enable {
        # clients that keep getting rate limited
        nginx-limit-req.settings = web;
        # scanners probing for wp-login, .env, phpmyadmin and friends
        nginx-botsearch.settings = accessLog;
      })

      # https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup
      (mkIf cfg.vaultwarden.enable {
        vaultwarden = vaultwardenJail ''^.*?Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$'';
        vaultwarden-admin = vaultwardenJail ''^.*?Invalid admin token\. IP: <ADDR>.*$'';
      })

      # api and git auth failures only show as 401s, and git sends one before
      # every authenticated request, so it gets more tries
      (mkIf cfg.forgejo.enable {
        forgejo = journalJail "forgejo" [
          ''^.*Failed authentication attempt for .* from <ADDR>(?::\d+)?:''
          ''^.*router: completed \S+ \S+ for <ADDR>:\d+, 401 Unauthorized''
        ] { maxretry = 10; };
      })
    ];
  };
}
