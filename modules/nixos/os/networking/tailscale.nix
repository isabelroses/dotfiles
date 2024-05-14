{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault optionals;
  inherit (config.services) tailscale;

  sys = config.modules.system.networking;
  cfg = sys.tailscale;
in
{
  config = mkIf cfg.enable {
    # make the tailscale command usable to users
    environment.systemPackages = [ pkgs.tailscale ];

    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "${tailscale.interfaceName}" ];
      checkReversePath = "loose";

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ tailscale.port ];
    };

    # enable tailscale, inter-machine VPN service
    services.tailscale = {
      enable = true;
      permitCertUid = "root";
      useRoutingFeatures = mkDefault "server";
      extraUpFlags =
        sys.tailscale.defaultFlags
        ++ optionals sys.tailscale.enable [ "--advertise-exit-node" ];
    };

    # server can't be client and client be server
    assertions = [
      (mkIf (cfg.isClient == cfg.isServer) {
        assertion = false;
        message = ''
          You have enabled both client and server features of the Tailscale service. Unless you are providing your own UpFlags, this is probably not what you want.
        '';
      })
    ];
  };
}
