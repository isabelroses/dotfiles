{ lib, config, ... }:
let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
in
{
  systemd = mkMerge [
    {
      # run shellcheck on the generated scripts for systemd units
      enableStrictShellChecks = true;
    }

    (mkIf config.garden.profiles.graphical.enable {
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
    })
  ];
}
