{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  # See
  # - https://docs.hetzner.com/cloud/servers/static-configuration/
  # - https://gist.github.com/nh2/6814728dc3bea1508323e9bf2213c28d#file-configuration-nix-L39-L65
  # - https://github.com/nix-community/nixos-install-scripts/issues/3#issuecomment-752781335
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
              address = "116.203.57.153";
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
              address = "2a01:4f8:c2c:b73d::/64";
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
}
