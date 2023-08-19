{lib, config, ...}: let
  inherit (lib) mkIf;
in {
  users.users.git = mkIf config.modules.services.gitea.enable {
    isSystemUser = true;
    extraGroups = [];
    useDefaultShell = true;
    home = "/var/lib/gitea";
    group = "gitea";
  };
}
