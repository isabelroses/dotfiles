{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.services.wakapi;
in {
  users = mkIf cfg.enable {
    groups.wakapi = {};

    users.wakapi = {
      isSystemUser = true;
      createHome = false;
      group = "wakapi";
    };
  };
}
