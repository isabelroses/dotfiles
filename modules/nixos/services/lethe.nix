{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkSecret mkService;

  cfg = config.garden.services.lethe;
in
{
  imports = [
    (mkService "lethe" { port = 7374; })
  ];

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
