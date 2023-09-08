{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.usrEnv.services;
in {
  users = {
    groups.wakapi = mkIf cfg.wakapi.enable {};
    users = {
      git = mkIf cfg.gitea.enable {
        isSystemUser = true;
        extraGroups = [];
        useDefaultShell = true;
        home = "/var/lib/gitea";
        group = "gitea";
      };
      wakapi = mkIf cfg.wakapi.enable {
        isSystemUser = true;
        group = "wakapi";
      };
      /*
      cloudflared = mkIf config.modules.usrEnv.services.cloudflared.enable {
        isSystemUser = true;
        extraGroups = [];
        useDefaultShell = true;
        home = "/var/lib/cloudflared";
        group = "cloudflared";
      };
      */
    };
  };
}
