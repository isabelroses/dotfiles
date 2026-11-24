{
  lib,
  name,
  config,
  options,
  ...
}:
let
  inherit (lib.lists) optional;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    anything
    attrsOf
    deferredModule
    enum
    listOf
    nullOr
    str
    submodule
    ;

  address =
    description: example:
    mkOption {
      type = nullOr str;
      default = null;
      inherit description example;
    };

  files = builtins.filter builtins.pathExists (
    map (file: ./${name}/${file}) [
      "default.nix"
      "hardware.nix"
      "users.nix"
    ]
  );

  garden = removeAttrs config (builtins.attrNames options);
in
{
  freeformType = attrsOf anything;

  options = {
    arch = mkOption {
      type = str;
      default = "x86_64";
      description = "The host's cpu architecture, which the flake builds it for";
    };

    class = mkOption {
      type = enum [
        "nixos"
        "darwin"
        "iso"
        "unmanaged"
      ];
      default = "nixos";
      description = "What the flake builds the host as. unmanaged hosts aren't built, but the fleet still monitors them";
    };

    description = mkOption {
      type = str;
      default = "";
      description = "One line about the host, for its docs page and the systems table";
    };

    location = mkOption {
      type = enum [
        "cloud"
        "home"
        "roaming"
      ];
      default = "cloud";
      description = "Where the host sits, which groups it in the topology diagram";
    };

    ipv4 = address "The IPv4 address on the host's primary interface" "203.0.113.10";
    ipv6 = address "The IPv6 address on the host's primary interface" "2001:db8::1";
    tailnetIp = address "The host's address on the tailnet" "100.64.0.1";
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
            description = "The garden.services the relay serves, at the port and domain this host gives them";
          };
        };
      });
      default = null;
      description = "Public services this host can't serve itself, usually because it sits behind NAT";
    };

    modules = mkOption {
      type = listOf deferredModule;
      readOnly = true;
      internal = true;
      default =
        files
        ++ optional (garden != { }) {
          _file = ./fleet.toml;
          inherit garden;
        };
      description = "What the host is built from beyond its class: its garden config and the nix in systems/<host>";
    };
  };
}
