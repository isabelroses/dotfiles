# host-wide jails; services that need their own declare them next to the
# service, with self.lib.journalJail
{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (self.lib.fail2ban) web;

  # nginx's access log goes to a file rather than the journal
  accessLog = web // {
    backend = "auto";
    logpath = "/var/log/nginx/access.log";
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

      (mkIf config.services.nginx.enable {
        # clients that keep getting rate limited
        nginx-limit-req.settings = web;
        # scanners probing for wp-login, .env, phpmyadmin and friends
        nginx-botsearch.settings = accessLog;
      })
    ];
  };
}
