{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.networking) domain;
in {
  services.wakapi = lib.mkIf config.modules.usrEnv.services.wakapi.enable {
    enable = true;
    package = pkgs.wakapi;

    domain = "wakapi.${domain}";
    port = 15912;
    nginx.enable = true;
    passwordSaltFile = config.sops.secrets.wakapi.path;
    settings = {
      app.avatar_url_template = "https://www.gravatar.com/avatar/{email_hash}.png";
      mail.enabled = false;
      security = {
        allow_signup = false;
        disable_frontpage = true;
      };
    };
  };
}
