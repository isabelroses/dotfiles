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
        (mkConnection "skadi" "eth0")
        (mkConnection "router" "eth0")

        (mkConnection "upcloud" "eth0")
      ];
    };

    intranet =
      mkInternet {
        connections = map (device: mkConnection device "tailscale0") [
          "amaterasu"
          "freyja"
          "tatsumaki"
          "minerva"
          "skadi"
          "isis"
        ];
      }
      // {
        name = "Intranet";
      };

    # my homes router router
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
        eth1 = mkConnection "amaterasu" "eth0";
        wlan0 = [
          (mkConnection "freyja" "wlan0")
          (mkConnection "amaterasu" "wlan0")
          (mkConnection "tatsumaki" "wlan0")
        ];
      };
    };

    upcloud = mkRouter "upcloud" {
      info = "upcloud";

      interfaceGroups = [
        [ "eth0" ]
        [ "eth1" ]
      ];

      interfaces = {
        eth1.network = "upcloud";
      };

      connections = {
        eth1 = mkConnection "isis" "eth0";
      };
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

    freyja = {
      hardware.info = "A small computer i picked up and now my media server";
      interfaces.wlan0 = { };
    };

    isis = {
      hardware.info = "Minimal server for monitoring tgirl.cloud services";
      interfaces.eth0 = { };
    };

    minerva.hardware.info = "This is the orginal server, hosting most of my personal services";

    skadi = {
      hardware.info = "Oracle free server, mostly used for the pds and aarch64 builds";
      interfaces.eth0 = { };
    };

    tatsumaki = mkDevice "tatsumaki" {
      info = "A MacBook Air";
      deviceIcon = ./assets/mac.png;
      interfaces = {
        wlan0 = { };
        tailscale0 = { };
      };
    };
    # keep-sorted end
  };

  networks = {
    upcloud = {
      name = "upcloud";
      cidrv4 = "10.0.0.0/24";
    };

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
