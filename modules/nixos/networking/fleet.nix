{ lib, config, ... }:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    attrsOf
    listOf
    nullOr
    port
    str
    submodule
    ;

  lan = config.garden.fleet.${config.networking.hostName}.lan or null;
  cfg = config.garden.networking.lan;

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
          lan = address "The interface facing the home LAN" "wlan0";
          # a literal address rather than a MagicDNS name, since nginx resolves
          # upstreams once at startup and would fail to start if tailscale wasn't up
          tailscale = address "The host's tailnet IPv4 address" "100.64.0.1";
          ipv4 = address "The IPv4 address on the host's primary interface" "203.0.113.10";
          ipv6 = address "The IPv6 address on the host's primary interface" "2001:db8::1";
        };
      });
      default = { };
      description = "Facts about every host, identical on all of them, so no host has to evaluate another to learn about it";
    };

    networking.lan = {
      allowedTCPPorts = mkOption {
        type = listOf port;
        default = [ ];
        description = "TCP ports opened only on this host's LAN interface";
      };

      allowedUDPPorts = mkOption {
        type = listOf port;
        default = [ ];
        description = "UDP ports opened only on this host's LAN interface";
      };
    };
  };

  config = {
    garden.fleet = {
      freyja = {
        lan = "enp6s0";
        tailscale = "100.69.230.34";
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

    assertions = [
      {
        assertion = lan != null || (cfg.allowedTCPPorts == [ ] && cfg.allowedUDPPorts == [ ]);
        message = "garden.networking.lan opens ports but ${config.networking.hostName} has no `lan` in garden.fleet";
      }
    ];

    networking.firewall.interfaces = optionalAttrs (lan != null) {
      ${lan} = { inherit (cfg) allowedTCPPorts allowedUDPPorts; };
    };
  };
}
