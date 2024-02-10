{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) device;
  acceptedTypes = ["desktop" "laptop" "wsl" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    services = {
      # enable GVfs, a userspace virtual filesystem.
      gvfs.enable = true;

      # thumbnail support on thunar
      tumbler.enable = true;

      # storage daemon required for udiskie auto-mount
      udisks2.enable = true;

      dbus = {
        packages = with pkgs; [dconf gcr udisks2];
        enable = true;
        # Use the faster dbus-broker instead of the classic dbus-daemon
        implementation = "broker";
      };

      # disable chrony in favor if systemd-timesyncd
      timesyncd.enable = lib.mkDefault true;
      chrony.enable = lib.mkDefault false;

      # https://dataswamp.org/~solene/2022-09-28-earlyoom.html
      # avoid the linux kernel from locking itself when we're putting too much strain on the memory
      # this helps avoid having to shut down forcefully when we OOM
      earlyoom = {
        enable = true;
        enableNotifications = true; # annoying, but we want to know what's killed
        freeSwapThreshold = 2;
        freeMemThreshold = 2;
        extraArgs = [
          "-g"
          "--avoid 'Hyprland|soffice|soffice.bin|firefox)$'" # things we want to not kill
          "--prefer '^(electron|.*.exe)$'" # I wish we could kill electron permanently
        ];

        # we should ideally write the logs into a designated log file; or even better, to the journal
        # for now we can hope this echo sends the log to somewhere we can observe later
        killHook = pkgs.writeShellScript "earlyoom-kill-hook" ''
          echo "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed"
        '';
      };
    };

    systemd = let
      extraConfig = ''
        DefaultTimeoutStopSec=15s
      '';
    in {
      inherit extraConfig;
      user = {inherit extraConfig;};

      services = {
        "getty@tty1".enable = false; # if you want to use tty1 enable
        "autovt@tty1".enable = false;
        "getty@tty7".enable = false;
        "autovt@tty7".enable = false;
      };
    };
  };
}
