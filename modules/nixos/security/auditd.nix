{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    types
    ;

  cfg = config.garden.system.security;
in
{
  options.garden.system.security.auditd = {
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

  config = mkIf cfg.auditd.enable {
    security = {
      auditd.enable = true;
      audit = {
        enable = true;
        backlogLimit = 8192;
        failureMode = "printk";
        rules = [ "-a exit,always -F arch=b64 -S execve" ];
      };
    };

    systemd = {
      timers."clean-audit-log" = {
        description = "Periodically clean audit log";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };

      # clean audit log if it's more than 524,288,000 bytes, which is roughly 500 megabytes
      # it can grow MASSIVE in size if left unchecked
      services."clean-audit-log" = {
        script = ''
          set -eu
          if [[ $(stat -c "%s" /var/log/audit/audit.log) -gt 524288000 ]]; then
            echo "Clearing Audit Log";
            rm -rvf /var/log/audit/audit.log;
            echo "Done!"
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };
}
