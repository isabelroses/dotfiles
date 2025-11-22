{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkForce;
in
{
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

      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];

      # allow servers to be pinnged, but not our clients
      allowPing = config.garden.profiles.server.enable;

      # make a much smaller and easier to read log
      logReversePathDrops = true;
      logRefusedConnections = false;

      # Don't filter DHCP packets, according to nixops-libvirtd
      checkReversePath = mkForce false;
    };
  };
}
