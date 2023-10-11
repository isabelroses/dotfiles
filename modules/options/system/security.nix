{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mdDoc types;
in {
  options.modules.system.security = {
    fixWebcam = mkEnableOption (mdDoc "Fix the purposefully broken webcam by un-blacklisting the related kernel module.");
    tor.enable = mkEnableOption (mdDoc "Tor daemon");
    lockModules = mkEnableOption (mdDoc "Lock kernel modules to the ones specified in the configuration. Highly breaking.");

    auditd = {
      enable = mkEnableOption (mdDoc "Enable the audit daemon.");
      autoPrune = {
        enable = mkEnableOption (mdDoc "Enable auto-pruning of audit logs.");

        size = mkOption {
          type = types.int;
          default = 524288000; # roughly 500 megabytes
          description = "The maximum size of the audit log in bytes.";
        };

        dates = mkOption {
          type = types.str;
          default = "daily";
          example = "weekly";
          description = "How often cleaning is triggered. Passed to systemd.time";
        };
      };
    };

    clamav = {
      enable = mkEnableOption (mdDoc "Enable ClamAV daemon.");

      daemon = {
        settings = mkOption {
          type = with types; attrsOf (oneOf [bool int str (listOf str)]);
          default = {
            LogFile = "/var/log/clamd.log";
            LogTime = true;
            VirusEvent = lib.escapeShellArgs [
              "${pkgs.libnotify}/bin/notify-send"
              "--"
              "ClamAV Virus Scan"
              "Found virus: %v"
            ];
            DetectPUA = true;
          };
          description = lib.mdDoc ''
            ClamAV configuration. Refer to <https://linux.die.net/man/5/clamd.conf>,
            for details on supported values.
          '';
        };
      };

      updater = {
        enable = mkEnableOption (lib.mdDoc "ClamAV freshclam updater");

        frequency = mkOption {
          type = types.int;
          default = 12;
          description = lib.mdDoc ''
            Number of database checks per day.
          '';
        };

        interval = mkOption {
          type = types.str;
          default = "hourly";
          description = lib.mdDoc ''
            How often freshclam is invoked. See systemd.time(7) for more
            information about the format.
          '';
        };

        settings = mkOption {
          type = with types; attrsOf (oneOf [bool int str (listOf str)]);
          default = {};
          description = lib.mdDoc ''
            freshclam configuration. Refer to <https://linux.die.net/man/5/freshclam.conf>,
            for details on supported values.
          '';
        };
      };
    };
  };
}
