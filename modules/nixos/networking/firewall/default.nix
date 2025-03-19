{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (config.garden) meta;
  inherit (self.lib.validators) hasProfile;
in
{
  imports = [ ./fail2ban.nix ];

  config = {
    # TODO: IFD, we can remove that by getting the default config from
    # https://github.com/evilsocket/opensnitch/blob/master/daemon/default-config.json
    #
    # enable opensnitch firewall
    # inactive until opensnitch UI is opened
    # services.opensnitch.enable = device.type != "server";

    networking.firewall = {
      enable = true;
      package = pkgs.iptables;

      allowedTCPPorts = [
        443
        8080
      ];
      allowedUDPPorts = [ ];

      allowedTCPPortRanges = mkIf meta.kdeconnect [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = mkIf meta.kdeconnect [
        {
          from = 1714;
          to = 1764;
        }
      ];

      # allow servers to be pinnged, but not our clients
      allowPing = hasProfile config [ "server" ];

      # make a much smaller and easier to read log
      logReversePathDrops = true;
      logRefusedConnections = false;

      # Don't filter DHCP packets, according to nixops-libvirtd
      checkReversePath = mkForce false;
    };
  };
}
