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
          (mkConnection "hydra" "wlan0")
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

    # extra settings for devices that are collected by nix-topology
    amaterasu = {
      hardware.info = "My high-end gaming machine";

      interfaces = {
        eth0 = { };
        wlan0 = { };
      };
    };

    hydra = {
      hardware.info = "A super mid spec laptop";
      interfaces.wlan0 = { };
    };

    minerva.hardware.info = "A server for some of my infrastructure";

    valkyrie = {
      hardware.info = "WSL2 host, devenv on Windows";

      guestType = "wsl";
      parent = "amaterasu";
    };
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
