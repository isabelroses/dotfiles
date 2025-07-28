{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf genAttrs;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    systemd = {
      settings.Manager = {
        DefaultTimeoutStartSec = "15s";
        DefaultTimeoutStopSec = "15s";
        DefaultTimeoutAbortSec = "15s";
        DefaultDeviceTimeoutSec = "15s";
      };

      user.extraConfig = ''
        DefaultTimeoutStartSec=15s
        DefaultTimeoutStopSec=15s
        DefaultTimeoutAbortSec=15s
        DefaultDeviceTimeoutSec=15s
      '';

      services =
        genAttrs
          [
            "getty@tty1"
            "autovt@tty1"
            "getty@tty7"
            "autovt@tty7"
            "kmsconvt@tty1"
            "kmsconvt@tty7"
          ]
          (_: {
            enable = false;
          });
    };
  };
}
