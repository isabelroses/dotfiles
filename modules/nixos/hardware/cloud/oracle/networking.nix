{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkForce;

  cfg = config.garden.profiles.oracle;

  inherit (config.networking) hostName;
  fleet = config.garden.fleet.${hostName} or { };
  ipv4 = fleet.ipv4 or null;
  ipv6 = fleet.ipv6 or null;
in
{
  # <https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingIPaddresses.htm>
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = ipv4 != null;
        message = "${hostName} needs ipv4 in garden.fleet";
      }
    ];

    networking = {
      networkmanager.enable = mkForce false;

      # with no ipv6 in the fleet, turn it off so nothing tries a route that
      # goes nowhere
      enableIPv6 = ipv6 != null;

      nameservers = [ "169.254.169.254" ];
      search = [ "vcn04081257.oraclevcn.com" ];

      defaultGateway = {
        address = "10.0.0.1";
        interface = "eth0";
      };

      defaultGateway6 = mkIf (ipv6 != null) {
        address = "fe80::200:17ff:feb0:5c74";
        interface = "eth0";
      };

      interfaces.eth0 = {
        mtu = 9000;

        ipv4 = {
          addresses = [
            {
              address = ipv4;
              prefixLength = 24;
            }
          ];

          # the resolver sits on a link local address, so it needs a route
          routes = [
            {
              address = "169.254.0.0";
              prefixLength = 16;
            }
          ];
        };

        ipv6 = mkIf (ipv6 != null) {
          addresses = [
            {
              address = ipv6;
              prefixLength = 128;
            }
          ];

          routes = [
            {
              address = "2603:c020:c011:9c00::";
              prefixLength = 64;
            }
          ];
        };
      };
    };
  };
}
