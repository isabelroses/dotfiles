{ lib, config, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  systemd = {
    # Systemd OOMd
    # Fedora enables these options by default. See the 10-oomd-* files here:
    # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
    oomd = {
      enable = !config.systemd.enableUnifiedCgroupHierarchy;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;
      extraConfig = {
        "DefaultMemoryPressureDurationSec" = "20s";
      };
    };

    services.nix-daemon.serviceConfig.OOMScoreAdjust = mkDefault 350;

    tmpfiles.rules = [
      # Enables storing of the kernel log (including stack trace) into pstore upon a panic or crash.
      "w /sys/module/kernel/parameters/crash_kexec_post_notifiers - - - - Y"
      # Enables storing of the kernel log upon a normal shutdown (shutdown, reboot, halt).
      "w /sys/module/printk/parameters/always_kmsg_dump - - - - N"
    ];
  };
}
