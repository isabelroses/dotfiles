{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.lethe;
in
{
  options.garden.services.lethe = mkServiceOption "lethe" {
    port = 7374;
  };

  config = mkIf cfg.enable {
    sops.secrets.lethe-token = mkSecret {
      file = "lethe";
      key = "token";
    };

    services.lethe-server = {
      enable = true;

      settings = {
        listenAddress = cfg.host;
        inherit (cfg) port;
        tokenFile = config.sops.secrets.lethe-token.path;
      };
    };
  };
}
