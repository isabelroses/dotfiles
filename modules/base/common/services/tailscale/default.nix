{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.services.tailscale) interfaceName port;
  inherit (lib) mkIf optionals;

  cfg = config.modules.system.networking.tailscale;
in {
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [tailscale];

    networking.firewall = {
      trustedInterfaces = [interfaceName];
      checkReversePath = mkIf cfg.client.enable "loose";
      allowedUDPPorts = [port];
    };

    # https://tailscale.com/kb/1019/subnets/?tab=linux#step-1-install-the-tailscale-client
    boot.kernel.sysctl = mkIf cfg.server.enable {
      "net.ipv4.ip_forward" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures =
        if cfg.server.enable
        then "server"
        else "client";
      extraUpFlags =
        [
          "--ssh"
        ]
        ++ optionals cfg.server.enable [
          "--advertise-exit-node"
        ];
    };
  };
}
