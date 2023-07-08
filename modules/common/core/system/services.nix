{
  lib,
  pkgs,
  config,
  ...
}: let
  cloudflare = config.modules.services.cloudflare;
in {
  services = {
    # monitor and control temparature
    thermald.enable = true;
    # handle ACPI events
    acpid.enable = true;
    # discard blocks that are not in use by the filesystem, good for SSDs
    fstrim.enable = true;
    # firmware updater for machine hardware
    fwupd.enable = true;
    # I don't use lvm, can be disabled
    lvm.enable = lib.mkDefault false;
    # enable smartd monitoering
    smartd.enable = true;
    # limit systemd journal size
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      SystemMaxFileSize=50M
    '';
  };
  users.groups.cloudflared = lib.mkIf (cloudflare.enable) {};
  systemd = with lib; {
    services.tunnel = mkIf (cloudflare.enable) {
      wantedBy = ["multi-user.target"];
      after = ["network.target" "network-online.target" "systemd-resolved.service"];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${cloudflare.token}";
        Restart = "always";
        User = "${config.modules.system.username}";
        Group = "cloudflared";
      };
    };

    # a systemd timer to clean /var/log/audit.log daily
    # this can probably be weekly, but daily means we get to clean it every 2-3 days instead of once a week
    timers."clean-audit-log" = mkIf (config.security.auditd.enable) {
      description = "Periodically clean audit log";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    # clean audit log if it's more than 524,288,000 bytes, which is roughly 500 megabytes
    # it can grow MASSIVE in size if left unchecked
    services."clean-audit-log" = mkIf (config.security.auditd.enable) {
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
