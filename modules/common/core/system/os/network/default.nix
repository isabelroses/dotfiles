{
  lib,
  config,
  ...
}:
with lib; {
  imports = [
    ./blocker.nix
    ./firewall.nix
    ./ssh.nix
    ./optimise.nix
  ];

  services = {
    # systemd DNS resolver daemon
    resolved.enable = true;
  };

  networking = {
    # generate a host ID by hashing the hostname
    hostId = builtins.substring 0 8 (
      builtins.hashString "md5" config.networking.hostName
    );

    hostName = config.modules.system.hostname;
    # global dhcp has been deprecated upstream
    # use networkd instead
    # individual interfaces are still managed through dhcp in hardware configurations
    useDHCP = mkDefault false;
    useNetworkd = mkDefault true;

    # dns
    nameservers = [
      # cloudflare, yuck
      # shares data
      "1.1.1.1"
      "1.0.0.1"

      # quad9, said to be the best
      # shares *less* data
      "9.9.9.9"
    ];

    networkmanager = {
      enable = true;
      plugins = [];
      dns = "systemd-resolved";
      unmanaged = ["docker0" "rndis0"];
      wifi = {
        # The bellow is disabled as my uni hated me for it
        # macAddress = "random"; # use a random mac address on every boot, this can scew with static ip
        powersave = true;
        scanRandMacAddress = true; # MAC address randomization of a Wi-Fi device during scanning
      };
      ethernet.macAddress = "random";
    };
  };

  # enable wireless database, it helps with finding the right channels
  hardware.wirelessRegulatoryDatabase = true;

  # allow for the system to boot without waiting for the network interfaces are online
  # speeds up boot times
  systemd = let
    ethernetDevices = [
      "wlp1s0f0u8" # wifi dongle
      "enp7s0" # ethernet interface on the motherboard
    ];
  in {
    network.wait-online.enable = false;
    services =
      {
        NetworkManager-wait-online.enable = false;

        # disable networkd and resolved from being restarted on configuration changes
        systemd-networkd.stopIfChanged = false;
        systemd-resolved.stopIfChanged = false;
      }
      // lib.concatMapAttrs (_: v: v) (lib.genAttrs ethernetDevices (device: {
        # Assign an IP address when the device is plugged in rather than on startup. Needed to prevent
        # blocking the boot sequence when the device is unavailable, as it is hotpluggable.
        "network-addresses-${device}".wantedBy = lib.mkForce ["sys-subsystem-net-devices-${device}.device"];
      }));
  };
}
