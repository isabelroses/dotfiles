{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.services;
in {
  users = {
    groups = {
      wakapi = mkIf cfg.wakapi.enable {};
      git = mkIf cfg.gitea.enable {};
    };

    users = {
      git = mkIf cfg.gitea.enable {
        isSystemUser = true;
        createHome = false;
        group = "git";
      };
      wakapi = mkIf cfg.wakapi.enable {
        isSystemUser = true;
        group = "wakapi";
      };
    };
  };
}
