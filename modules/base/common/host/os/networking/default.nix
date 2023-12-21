{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce genAttrs;

  dev = config.modules.device;
  sys = config.modules.system;
in {
  imports = [
    ./firewall

    ./blocker.nix
    ./ssh.nix
    ./optimise.nix
    ./tailscale.nix
    ./tcpcrypt.nix
  ];

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

    # dns
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "9.9.9.9"
    ];

    wireless = {
      enable = sys.networking.wirelessBackend == "wpa_supplicant";
      userControlled.enable = true;
      iwd = {
        enable = sys.networking.wirelessBackend == "iwd";
        settings = {
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };

    networkmanager = {
      enable = true;
      plugins = mkForce [];
      dns = "systemd-resolved";
      unmanaged = [
        "docker0"
        "rndis0"
        "interface-name:br-*"
        "interface-name:docker*"
        "interface-name:virbr*"
        "driver:wireguard" # don't manage wireguard, we want to do it outselves
      ];

      wifi = {
        backend = sys.networking.wirelessBackend; # this can be iwd or wpa_supplicant, use wpa_s until iwd support is stable
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
