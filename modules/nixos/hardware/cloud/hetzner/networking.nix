{ lib, config, ... }:
let
  inherit (lib) mkIf mkForce mkOption;

  cfg = config.garden.profiles.server.hetzner;
in
{
  options.garden.profiles.server.hetzner = {
    ipv4 = mkOption {
      type = lib.types.str;
      description = ''
        The IPv4 address to assign to the server.
        This should be a single IP address, not a range.
      '';
    };

    ipv6 = mkOption {
      type = lib.types.str;
      description = ''
        The IPv6 address to assign to the server.
        This should be a single IP address, not a range.
      '';
    };
  };

  # See
  # - https://docs.hetzner.com/cloud/servers/static-configuration/
  # - https://gist.github.com/nh2/6814728dc3bea1508323e9bf2213c28d#file-configuration-nix-L39-L65
  # - https://github.com/nix-community/nixos-install-scripts/issues/3#issuecomment-752781335
  config = mkIf cfg.enable {
    networking = {
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

      interfaces = {
        eth0 = {
          ipv4 = {
            addresses = [
              {
                address = cfg.ipv4;
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
                address = cfg.ipv6;
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
