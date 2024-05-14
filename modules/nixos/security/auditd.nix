{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.modules.system.security;
in
{
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
