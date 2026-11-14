{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    attrsOf
    listOf
    nullOr
    str
    submodule
    ;

  self' = config.garden.fleet.${config.networking.hostName} or { };
  # not every host has an entry
  wakeOnLan = self'.wakeOnLan or null;
  relay = self'.relay or null;

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

          relay = mkOption {
            type = nullOr (submodule {
              options = {
                via = mkOption {
                  type = str;
                  example = "minerva";
                  description = "The host that serves this host's public services and proxies them to it over tailscale";
                };

                services = mkOption {
                  type = listOf str;
                  example = [ "immich" ];
                  description = "The garden.services the relay serves, at their domain and port";
                };
              };
            });
            default = null;
            description = "Public services this host can't serve itself, usually because it sits behind NAT";
          };
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
        # behind a home NAT
        relay = {
          via = "minerva";
          services = [
            "immich"
            "jellyfin"
          ];
        };
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

    # the relay reaches these over tailscale, so they have to be running and
    # listening beyond loopback
    assertions = lib.lists.optionals (relay != null) (
      lib.lists.concatMap (
        name:
        let
          service = config.garden.services.${name};
        in
        [
          {
            assertion = service.enable;
            message = "${relay.via} relays ${name}, but it isn't enabled here";
          }
          {
            assertion = (service.host or "0.0.0.0") != "127.0.0.1";
            message = "${relay.via} relays ${name} over tailscale, but it only listens on loopback";
          }
        ]
      ) relay.services
    );

    networking = mkIf (wakeOnLan != null) {
      interfaces.${wakeOnLan}.wakeOnLan.enable = true;
      firewall.allowedUDPPorts = [ 9 ];
    };
  };
}
