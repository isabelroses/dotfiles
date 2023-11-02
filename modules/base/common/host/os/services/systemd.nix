{
  lib,
  config,
  ...
}: {
  systemd =
    {
      # Systemd OOMd
      # Fedora enables these options by default. See the 10-oomd-* files here:
      # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
      oomd = {
        enableRootSlice = true;
        enableUserServices = true;
        enableSystemSlice = true;
      };
    }
    // lib.optionalAttrs config.security.auditd.enable {
      # a systemd timer to clean /var/log/audit.log daily
      timers."clean-audit-log" = {
        description = "Periodically clean audit log";
        wantedBy = ["timers.target"];
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
}
