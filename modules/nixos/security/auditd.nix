{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int str;

  cfg = config.garden.system.security.auditd;
in
{
  options.garden.system.security.auditd = {
    enable = mkEnableOption "Enable the audit daemon";

    autoPrune = {
      enable = mkEnableOption "Enable auto-pruning of audit logs" // {
        default = cfg.enable;
      };

      size = mkOption {
        type = int;
        default = 524288000; # ~500 megabytes
        description = "The maximum size of the audit log in bytes";
      };

      dates = mkOption {
        type = str;
        default = "daily";
        example = "weekly";
        description = "How often the audit log should be pruned";
      };
    };
  };

  config = mkIf cfg.enable {
    security = {
      auditd.enable = true;

      audit = {
        enable = true;
        backlogLimit = 8192;
        failureMode = "printk";
        rules = [ "-a exit,always -F arch=b64 -S execve" ];
      };
    };

    # the audit log can grow quite large, so we _can_ automatically prune it
    systemd = mkIf cfg.autoPrune.enable {
      timers."clean-audit-log" = {
        description = "Periodically clean audit log";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.autoPrune.dates;
          Persistent = true;
        };
      };

      services."clean-audit-log" = {
        script = ''
          set -eu
          if [[ $(stat -c "%s" /var/log/audit/audit.log) -gt ${toString cfg.autoPrune.size} ]]; then
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
