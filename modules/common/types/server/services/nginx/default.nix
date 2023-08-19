{
  lib,
  config,
  ...
}:
with lib; let
  device = config.modules.device;
  acceptedTypes = ["server" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    networking.domain = "isabelroses.com";

    security = {
      acme = {
        acceptTerms = true;
        defaults.email = "isabel@isabelroses.com";
      };
    };

    services.nginx = {
      enable = true;
      commonHttpConfig = ''
        real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
      '';

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = let
        template = {
          forceSSL = true;
          enableACME = true;
        };
      in {
        # website + other stuff
        "isabelroses.com" = mkIf (config.modules.services.isabelroses-web.enable)
          template
          // {
            serverAliases = ["isabelroses.com"];
            root = "/home/isabel/dev/isabelroses.com-pub";
          };
        # vaultwawrden
        "vault.isabelroses.com" =
          mkIf (config.modules.services.vaultwarden.enable)
          template
          // {
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
              extraConfig = "proxy_pass_header Authorization;";
            };
          };
        # gitea
        "git.isabelroses.com" =
          mkIf (config.modules.services.gitea.enable)
          template
          // {
            locations."/".proxyPass = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}";
          };

        # mailserver
        "mail.isabelroses.com" = mkIf (config.modules.services.mailserver.enable) template;

        # webmail
        "webmail.isabelroses.com" = mkIf (config.modules.services.mailserver.enable) template;

        "search.isabelroses.com" = mkIf (config.modules.services.searxng.enable)
          template
          // {
            locations."/".proxyPass = "http://127.0.0.1:8888";
            extraConfig = ''
              access_log /dev/null;
              error_log /dev/null;
              proxy_connect_timeout 60s;
              proxy_send_timeout 60s;
              proxy_read_timeout 60s;
            '';
          };
      };
    };
  };
}
