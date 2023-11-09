{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options.modules.system.security = {
    fixWebcam = mkEnableOption "Fix the purposefully broken webcam by un-blacklisting the related kernel module.";
    tor.enable = mkEnableOption "Tor daemon";
    lockModules = mkEnableOption "Lock kernel modules to the ones specified in the configuration. Highly breaking.";

    selinux = {
      enable = mkEnableOption "system SELinux support + kernel patches";
      state = mkOption {
        type = with types; enum ["enforcing" "permissive" "disabled"];
        default = "enforcing";
        description = ''
          SELinux state to boot with. The default is enforcing.
        '';
      };

      type = mkOption {
        type = with types; enum ["targeted" "minimum" "mls"];
        default = "targeted";
        description = ''
          SELinux policy type to boot with. The default is targeted.
        '';
      };
    };

    auditd = {
      enable = mkEnableOption "Enable the audit daemon.";
      autoPrune = {
        enable = mkEnableOption "Enable auto-pruning of audit logs.";

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
      enable = mkEnableOption "Enable ClamAV daemon.";

      daemon = {
        settings = mkOption {
          type = with types; attrsOf (oneOf [bool int str (listOf str)]);
          default = {
            LogFile = "/var/log/clamd.log";
            LogTime = true;
            DetectPUA = true;
            VirusEvent = lib.escapeShellArgs [
              "${pkgs.libnotify}/bin/notify-send"
              "--"
              "ClamAV Virus Scan"
              "Found virus: %v"
            ];
          };

          description = ''
            ClamAV configuration. Refer to <https://linux.die.net/man/5/clamd.conf>,
            for details on supported values.
          '';
        };
      };

      updater = {
        enable = mkEnableOption "ClamAV freshclam updater";

        frequency = mkOption {
          type = types.int;
          default = 12;
          description = ''
            Number of database checks per day.
          '';
        };

        interval = mkOption {
          type = types.str;
          default = "hourly";
          description = ''
            How often freshclam is invoked. See systemd.time(7) for more
            information about the format.
          '';
        };

        settings = mkOption {
          type = with types; attrsOf (oneOf [bool int str (listOf str)]);
          default = {};
          description = ''
            freshclam configuration. Refer to <https://linux.die.net/man/5/freshclam.conf>,
            for details on supported values.
          '';
        };
      };
    };
  };
}
