{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet
    mkDevice
    mkRouter
    mkConnection
    ;
in
{
  nodes = {
    internet = mkInternet {
      connections = [
        (mkConnection "minerva" "eth0")
        (mkConnection "hestia" "eth0")
        (mkConnection "skadi" "eth0")
        (mkConnection "router" "eth0")
      ];
    };

    # our router
    router = mkRouter "bingus" {
      info = "BT Home Hub 5";

      interfaceGroups = [
        [ "eth0" ]
        [
          "eth1"
          "eth2"
          "eth3"
        ]
        [ "wlan0" ]
      ];

      interfaces = {
        eth1.network = "LAN";
        wlan0.network = "WLAN";
      };

      connections = {
        eth1 = mkConnection "bongus" "eth0";
        eth2 = mkConnection "amaterasu" "eth0";
        wlan0 = [
          (mkConnection "athena" "wlan0")
          (mkConnection "amaterasu" "wlan0")
          (mkConnection "tatsumaki" "wlan0")
        ];
      };
    };

    # devices not collected by nix-topology
    bongus = mkDevice "bongus" {
      info = "Raspberry Pi 4";
      deviceIcon = ./assets/rpi.svg;
      interfaces = {
        eth0 = { };
        eth1 = { };
      };

      services.pihole = {
        name = "Pi-hole";
        icon = ./assets/pihole.png;
      };
    };

    tatsumaki = mkDevice "tatsumaki" {
      info = "A MacBook Air";
      deviceIcon = ./assets/mac.png;

      interfaces.wlan0 = { };
    };

    # extra settings for devices that are collected by nix-topology, hostname sorted
    #
    # keep-sorted start block=yes newline_separated=yes
    amaterasu = {
      hardware.info = "A powerful desktop dual booting windows 11";

      interfaces = {
        eth0 = { };
        wlan0 = { };
      };
    };

    athena = {
      hardware.info = "My oldest laptop, altogh this flake still supports it, its barely in use";
      interfaces.wlan0 = { };
    };

    bmo.hardware.info = "Robin's laptop";

    hestia.hardware.info = "The host of most tgirl.cloud services";

    minerva.hardware.info = "This is the orginal server, hosting most of my personal services";

    skadi = {
      hardware.info = "Oracle free server, mostly used for the pds and aarch64 builds";

      interfaces.eth0 = { };
    };

    valkyrie = {
      hardware.info = "A WSL2 instance, on amaterasu";

      guestType = "wsl";
      parent = "amaterasu";
    };

    wisp.hardware.info = "Robin's WSL2 system";
    # keep-sorted end
  };

  networks = {
    LAN = {
      name = "LAN";
      cidrv4 = "192.68.1.0/24";
    };

    WLAN = {
      name = "WLAN";
      cidrv4 = "192.68.2.0/24";
    };
  };
}
