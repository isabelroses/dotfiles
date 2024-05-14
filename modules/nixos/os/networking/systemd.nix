{ lib, ... }:
let
  inherit (lib) concatMapAttrs genAttrs mkForce;

  ethernetDevices = [
    "wlp1s0f0u8" # wifi dongle
    "enp7s0" # ethernet interface on the motherboard
  ];
in
{
  # systemd DNS resolver daemon
  services.resolved.enable = true;

  systemd = {
    # allow for the system to boot without waiting for the network interfaces are online
    network.wait-online.enable = false;

    services =
      {
        NetworkManager-wait-online.enable = false;

        # disable networkd and resolved from being restarted on configuration changes
        systemd-networkd.stopIfChanged = false;
        systemd-resolved.stopIfChanged = false;
      }
      // concatMapAttrs (_: v: v) (
        genAttrs ethernetDevices (device: {
          # Assign an IP address when the device is plugged in rather than on startup. Needed to prevent
          # blocking the boot sequence when the device is unavailable, as it is hotpluggable.
          "network-addresses-${device}".wantedBy = mkForce [ "sys-subsystem-net-devices-${device}.device" ];
        })
      );
  };
}
