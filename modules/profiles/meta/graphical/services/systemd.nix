{
  systemd =
    let
      extraConfig = ''
        DefaultTimeoutStartSec=15s
        DefaultTimeoutStopSec=15s
        DefaultTimeoutAbortSec=15s
        DefaultDeviceTimeoutSec=15s
      '';
    in
    {
      inherit extraConfig;
      user = {
        inherit extraConfig;
      };

      services = {
        "getty@tty1".enable = false;
        "autovt@tty1".enable = false;
        "getty@tty7".enable = false;
        "autovt@tty7".enable = false;
        "kmsconvt@tty1".enable = false;
        "kmsconvt@tty7".enable = false;
      };
    };
}
