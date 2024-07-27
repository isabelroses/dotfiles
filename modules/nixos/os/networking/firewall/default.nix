{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (config.garden) programs device;
in
{
  imports = [ ./fail2ban.nix ];

  config = {
    # enable opensnitch firewall
    # inactive until opensnitch UI is opened
    services.opensnitch.enable = device.type != "server";

    networking.firewall = {
      enable = true;
      package = pkgs.iptables;

      allowedTCPPorts = [
        443
        8080
      ];
      allowedUDPPorts = [ ];

      allowedTCPPortRanges = mkIf programs.gui.kdeconnect.enable [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = mkIf programs.gui.kdeconnect.enable [
        {
          from = 1714;
          to = 1764;
        }
      ];

      # allow servers to be pinnged, but not our clients
      allowPing = device.type == "server";

      # make a much smaller and easier to read log
      logReversePathDrops = true;
      logRefusedConnections = false;

      # Don't filter DHCP packets, according to nixops-libvirtd
      checkReversePath = mkForce false;
    };
  };
}
