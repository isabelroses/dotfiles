{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.services.smb;
in {
  config = mkIf cfg.enable {
    services = {
      # https://nixos.wiki/wiki/Samba
      # make shares visible for windows 10 clients
      samba-wsdd = {
        enable = true;
        openFirewall = true;
      };

      samba = {
        enable = true;
        openFirewall = true;
        securityType = "user";
        extraConfig = ''
          security = user
          guest account = nobody
        '';
        shares = {
          general = mkIf (cfg.host.general.enable) {
            path = "/general";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
          };
          private = (cfg.host.media.enable) {
            path = "/media";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "isabel";
            "force group" = "users";
          };
        };
      };
    };
  };
}
