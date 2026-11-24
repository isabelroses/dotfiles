{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.system.networking.unbound;
  tailscale = config.garden.system.networking.tailscale;
in
{
  options.garden.system.networking.unbound.enable =
    mkEnableOption "a local recursive, DNSSEC validating unbound in place of resolved";

  config = mkIf cfg.enable {
    services.resolved.enable = mkForce false;

    services.unbound = {
      enable = true;

      # unsigned zone under a signed ts.net
      settings = mkIf tailscale.enable {
        server.domain-insecure = [ tailscale.tailnet ];
        forward-zone = [
          {
            name = tailscale.tailnet;
            forward-addr = [ "100.100.100.100" ];
          }
        ];
      };
    };
  };
}
