{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services.vaultwarden;
  device = config.modules.device;
  acceptedTypes = ["server" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && cfg.enable) {
    # this forces the system to create backup folder
    systemd.services.backup-vaultwarden.serviceConfig = {
      User = "root";
      Group = "root";
    };

    services.vaultwarden = {
      enable = true;
      environmentFile = config.age.secrets.vaultwarden-env.path;
      backupDir = "/srv/storage/vaultwarden/backup";
      config = {
        DOMAIN = "https://vault.isabelroses.com";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        extendedLogging = true;
        invitationsAllowed = false;
        useSyslog = true;
        logLevel = "warn";
        showPasswordHint = false;
        signupsAllowed = false;
        signupsDomainsWhitelist = "isabelroses.com";
        signupsVerify = true;
        smtpAuthMechanism = "Login";
        smtpFrom = "vaultwarden@isabelroses.com";
        smtpFromName = "isabelroses's Vaultwarden Service";
        smtpHost = "mail.isabelroses.com";
        smtpPort = 465;
        smtpSecurity = "force_tls";
        dataDir = "/srv/storage/vaultwarden";
      };
    };
  };
}
