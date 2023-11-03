{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkForce mkIf;
  inherit (config.modules) device;
in {
  imports = [
    ./fail2ban.nix
    ./nftables.nix
  ];

  config = {
    services = {
      # enable opensnitch firewall
      # inactive until opensnitch UI is opened
      opensnitch.enable = true;
    };

    networking = {
      firewall = {
        enable = mkDefault true;
        package = mkDefault pkgs.iptables-nftables-compat;
        allowedTCPPorts = [
          443
          8080
        ];
        allowedUDPPorts = [];
        allowedTCPPortRanges = mkIf (device.type != "server") [
          {
            #KDEconnect
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = mkIf (device.type != "server") [
          {
            #KDEconnect
            from = 1714;
            to = 1764;
          }
        ];
        allowPing = device.type == "server";
        logReversePathDrops = true;
        logRefusedConnections = false;
        checkReversePath = mkForce false; # Don't filter DHCP packets, according to nixops-libvirtd
      };
    };
  };
}
