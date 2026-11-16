# the fleet is systems/fleet.toml: facts about every host and the garden.services
# each one runs. every host reads all of it, so no host has to evaluate another
{
  lib,
  self,
  config,
  options,
  ...
}:
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

  data = lib.trivial.importTOML "${self}/systems/fleet.toml";

  # not every host has an entry
  fleet = config.garden.fleet.${config.networking.hostName} or { };
  wakeOnLan = fleet.wakeOnLan or null;

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

          services = mkOption {
            # the same type as garden.services, so the relay sees typed values
            inherit (options.garden.services) type;
            default = { };
            example = {
              immich = {
                enable = true;
                host = "0.0.0.0";
              };
            };
            description = "The host's garden.services settings, which it takes as its own";
          };

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
                  description = "The garden.services the relay serves, at the port and domain this host gives them";
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
    garden = {
      fleet = data;

      # raw, so the typed defaults (enable = false and the fallbacks) stay out
      services = data.${config.networking.hostName}.services or { };
    };

    networking = mkIf (wakeOnLan != null) {
      interfaces.${wakeOnLan}.wakeOnLan.enable = true;
      firewall.allowedUDPPorts = [ 9 ];
    };
  };
}
