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
        (mkConnection "isis" "eth0")
        (mkConnection "isis" "eth2")
        (mkConnection "amity" "eth0")
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
          "amity"
        ];
      }
      // {
        name = "Intranet";
      };

    # my homes router router
    router = mkRouter "bingus" {
      info = "Cudy WR3000 v2";

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
        eth2.network = "LAN";
        eth3.network = "LAN";
        wlan0.network = "WLAN";
      };

      connections = {
        eth1 = mkConnection "amaterasu" "enp4s0";
        eth2 = mkConnection "freyja" "enp6s0";
        eth3 = mkConnection "pi" "eth0";
        wlan0 = mkConnection "tatsumaki" "wlan0";
      };
    };

    # extra settings for devices that are collected by nix-topology, hostname sorted
    #
    # keep-sorted start block=yes newline_separated=yes
    amaterasu.hardware.info = "A powerful desktop dual booting windows 11";

    # unmanaged, so nix-topology can't collect it from a nixosConfiguration
    amity = mkDevice "amity" {
      info = "Ubuntu on Oracle, a docker compose box published through a cloudflared tunnel";
      interfaces = {
        eth0 = { };
        tailscale0 = { };
      };

      services = {
        cobalt = {
          name = "Cobalt";
          icon = ./assets/cobalt.svg;
          info = "127.0.0.1:9000";
        };

        umami = {
          name = "Umami";
          icon = ./assets/umami.svg;
          info = "0.0.0.0:3000";
          details.db.text = "postgres 15";
        };

        linkwarden = {
          name = "Linkwarden";
          icon = ./assets/linkwarden.png;
          info = "127.0.0.1:3001";
          details.db.text = "postgres 16, meilisearch";
        };

        pufferpanel = {
          name = "PufferPanel";
          icon = ./assets/pufferpanel.png;
          info = "0.0.0.0:8080";
        };

        cloudflared = {
          name = "Cloudflared";
          icon = ./assets/cloudflared.svg;
        };

        alloy = {
          name = "Grafana Alloy";
          details.scrapes.text = "node-exporter, cadvisor";
        };
      };
    };

    freyja.hardware.info = "A small computer i picked up and now my media server";

    # upcloud gives eth0 public v4, eth1 the private utility network, eth2 public v6
    isis = {
      hardware.info = "UpCloud server for monitoring tgirl.cloud services";
      interfaces.eth0 = { };
    };

    minerva.hardware.info = "This is the original server, hosting most of my personal services";

    # not managed by the flake; home assistant reads its stats
    pi = mkDevice "pi" {
      info = "Raspberry Pi, the LAN's DNS ad blocker";
      deviceIcon = ./assets/rpi.svg;
      interfaces.eth0.addresses = [ "192.168.10.5" ];

      services.pihole = {
        name = "Pi-hole";
        icon = ./assets/pihole.png;
        info = "http://192.168.10.5:8089/admin";
        details.dns.text = "192.168.10.5:53";
      };
    };

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
    LAN = {
      name = "LAN";
      cidrv4 = "192.168.10.0/24";
    };

    WLAN = {
      name = "WLAN";
      cidrv4 = "192.168.10.0/24";
    };
  };
}
