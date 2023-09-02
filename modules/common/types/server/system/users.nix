{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  users.users = {
    git = mkIf config.modules.usrEnv.services.gitea.enable {
      isSystemUser = true;
      extraGroups = [];
      useDefaultShell = true;
      home = "/var/lib/gitea";
      group = "gitea";
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
}
