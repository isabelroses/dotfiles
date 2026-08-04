{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkForce;
in
{
  # <https://upcloud.com/docs/products/networking/public-network/>
  config = mkIf config.garden.profiles.upcloud.enable {
    networking.networkmanager.enable = mkForce false;

    systemd.network.networks = {
      "10-eth0" = {
        matchConfig.Name = "eth0";

        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
        };

        linkConfig.RequiredForOnline = "routable";
      };

      "20-eth1" = {
        matchConfig.Name = "eth1";

        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
        };

        dhcpV4Config.UseGateway = false;

        linkConfig.RequiredForOnline = "no";
      };

      "30-eth2" = {
        matchConfig.Name = "eth2";

        networkConfig.IPv6AcceptRA = true;

        linkConfig.RequiredForOnline = "no";
      };
    };
  };
}
