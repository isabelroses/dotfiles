{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkForce;

  cfg = config.garden.profiles.hetzner;

  inherit (config.networking) hostName;
  fleet = config.garden.fleet.${hostName} or { };
  ipv4 = fleet.ipv4 or null;
  ipv6 = fleet.ipv6 or null;
in
{
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = ipv4 != null && ipv6 != null;
        message = "${hostName} needs ipv4 and ipv6 in garden.fleet";
      }
    ];

    networking = {
      # see <https://community.hetzner.com/tutorials/install-and-configure-ntp>
      timeServers = [
        "ntp1.hetzner.de"
        "ntp2.hetzner.com"
        "ntp3.hetzner.net"
      ];

      # See
      # <https://docs.hetzner.com/cloud/servers/static-configuration>
      # <https://gist.github.com/nh2/6814728dc3bea1508323e9bf2213c28d#file-configuration-nix-L39-L65>
      # <https://github.com/nix-community/nixos-install-scripts/issues/3#issuecomment-752781335>
      defaultGateway = {
        address = "172.31.1.1";
        interface = "eth0";
      };

      defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };

      dhcpcd.enable = mkForce false;
      usePredictableInterfaceNames = mkForce false;

      # since we are statically configuring networking we can drop
      # network manager
      networkmanager.enable = mkForce false;

      interfaces = {
        eth0 = {
          ipv4 = {
            addresses = [
              {
                address = ipv4;
                prefixLength = 32;
              }
            ];

            routes = [
              {
                address = "172.31.1.1";
                prefixLength = 32;
              }
            ];
          };

          ipv6 = {
            addresses = [
              {
                address = ipv6;
                prefixLength = 64;
              }
              {
                address = "fe80::9400:3ff:fea1:ef91";
                prefixLength = 64;
              }
            ];

            routes = [
              {
                address = "fe80::1";
                prefixLength = 128;
              }
            ];
          };
        };
      };
    };

    services.udev.extraRules = ''
      ATTR{address}=="96:00:03:a1:ef:91", NAME="eth0"
    '';
  };
}
