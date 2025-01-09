{ lib, ... }:
let
  inherit (lib.attrsets) genAttrs;

  extraConfig = ''
    DefaultTimeoutStartSec=15s
    DefaultTimeoutStopSec=15s
    DefaultTimeoutAbortSec=15s
    DefaultDeviceTimeoutSec=15s
  '';
in
{
  systemd = {
    inherit extraConfig;
    user = { inherit extraConfig; };

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
}
