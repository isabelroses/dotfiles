{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.services.gitea;
in {
  users = mkIf cfg.enable {
    groups.git = {};

    users.git = {
      isSystemUser = true;
      createHome = false;
      group = "git";
    };
  };
}
