{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.options) mkOption;
  inherit (lib.types) str;

  cfg = config.garden.profiles.oracle;
in
{
  options.garden.profiles.oracle = {
    ipv4 = mkOption {
      type = str;
      description = ''
        The private IPv4 address to assign to the vnic.
        Oracle NATs the public address to this, so it is never seen by the os.
      '';
    };

    ipv6 = mkOption {
      type = str;
      description = ''
        The IPv6 address to assign to the vnic.
        Oracle hands this out as a /128 over dhcpv6.
      '';
    };
  };

  # <https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingIPaddresses.htm>
  config = mkIf cfg.enable {
    networking = {
      networkmanager.enable = mkForce false;

      nameservers = [ "169.254.169.254" ];
      search = [ "vcn04081257.oraclevcn.com" ];

      defaultGateway = {
        address = "10.0.0.1";
        interface = "eth0";
      };

      defaultGateway6 = {
        address = "fe80::200:17ff:feb0:5c74";
        interface = "eth0";
      };

      interfaces.eth0 = {
        mtu = 9000;

        ipv4 = {
          addresses = [
            {
              address = cfg.ipv4;
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

        ipv6 = {
          addresses = [
            {
              address = cfg.ipv6;
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
