{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    attrsOf
    nullOr
    str
    submodule
    ;

  wakeOnLan = config.garden.fleet.${config.networking.hostName}.wakeOnLan or null;

  address =
    description: example:
    mkOption {
      type = nullOr str;
      default = null;
      inherit description example;
    };
in
{
  options.garden = {
    fleet = mkOption {
      type = attrsOf (submodule {
        options = {
          ipv4 = address "The IPv4 address on the host's primary interface" "203.0.113.10";
          ipv6 = address "The IPv6 address on the host's primary interface" "2001:db8::1";
          wakeOnLan = address "The interface on which to enable Wake-on-LAN" "enp1s0";
        };
      });
      default = { };
      description = "Facts about every host, identical on all of them, so no host has to evaluate another to learn about it";
    };

  };

  config = {
    garden.fleet = {
      amaterasu = {
        wakeOnLan = "enp4s0";
      };

      freyja = {
        wakeOnLan = "enp6s0";
      };

      minerva = {
        ipv4 = "91.107.198.173";
        ipv6 = "2a01:4f8:c012:2f67::1";
      };

      skadi = {
        # oracle NATs the public address to this private one
        ipv4 = "10.0.0.11";
        # oracle doesn't route 2603:c020:c011:9c00:0:c069:1ff7:1ff3 to the
        # internet yet, so ipv6 stays off until the vcn does
      };
    };

    networking = mkIf (wakeOnLan != null) {
      interfaces.${wakeOnLan}.wakeOnLan.enable = true;
      firewall.allowedUDPPorts = [ 9 ];
    };
  };
}
