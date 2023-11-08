{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce genAttrs;

  dev = config.modules.device;
in {
  imports = [
    ./firewall

    ./blocker.nix
    ./ssh.nix
    ./optimise.nix
  ];

  users = {
    groups.tcpcryptd = {};
    users.tcpcryptd = {
      isSystemUser = true;
      group = "tcpcryptd";
    };
  };

  services = {
    # systemd DNS resolver daemon
    resolved.enable = true;
  };

  networking = {
    # generate a host ID by hashing the hostname
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

    hostName = config.modules.system.hostname;
    # global dhcp has been deprecated upstream, so we use networkd instead
    # however individual interfaces are still managed through dhcp in hardware configurations
    useDHCP = mkForce false;
    useNetworkd = mkForce true;

    # interfaces are assigned names that contain topology information (e.g. wlp3s0) and thus should be consistent across reboots
    # this already defaults to true, we set it in case it changes upstream
    usePredictableInterfaceNames = mkDefault true;

    # enable opportunistic TCP encryption
    # this is NOT a pancea, however, if the receiver supports encryption and the attacker is passive
    # privacy will be more plausible (but not guaranteed, unlike what the option docs suggest)
    tcpcrypt.enable = false;

    # dns
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "9.9.9.9"
    ];

    networkmanager = {
      enable = true;
      plugins = [];
      dns = "systemd-resolved";
      unmanaged = ["docker0" "rndis0"];

      wifi = {
        # backend = "iwd";
        # The below is disabled as my uni hated me for it
        # macAddress = "random"; # use a random mac address on every boot, this can scew with static ip
        powersave = true;
        scanRandMacAddress = true; # MAC address randomization of a Wi-Fi device during scanning
      };

      ethernet.macAddress = mkIf (dev.type != "server") "random"; # causes server to be unreachable over SSH
    };
  };

  # enable wireless database, it helps keeping wifi speedy
  hardware.wirelessRegulatoryDatabase = true;

  # allow for the system to boot without waiting for the network interfaces are online
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
      // lib.concatMapAttrs (_: v: v) (genAttrs ethernetDevices (device: {
        # Assign an IP address when the device is plugged in rather than on startup. Needed to prevent
        # blocking the boot sequence when the device is unavailable, as it is hotpluggable.
        "network-addresses-${device}".wantedBy = mkForce ["sys-subsystem-net-devices-${device}.device"];
      }));
  };
}
