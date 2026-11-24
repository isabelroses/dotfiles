{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.attrsets) attrNames;
  inherit (lib.lists) filter optional;
  inherit (lib.strings) removeSuffix;
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkSecret mkService;

  cfg = config.garden.services.grafana;
  services = config.garden.services;

  secret =
    key:
    mkSecret {
      file = "monitoring";
      inherit key;
      owner = "grafana";
    };

  sso = "https://${services.kanidm.domain}";

  local = service: "http://127.0.0.1:${toString services.${service}.port}";

  # every file in ./dashboards but the lib is one dashboard
  d = import ./dashboards/lib.nix { inherit lib; };
  dashboards = pkgs.linkFarm "grafana-dashboards" (
    map (file: rec {
      name = "${removeSuffix ".nix" file}.json";
      path = pkgs.writeText name (builtins.toJSON (import ./dashboards/${file} { inherit d; }));
    }) (filter (file: file != "lib.nix") (attrNames (builtins.readDir ./dashboards)))
  );
in
{
  imports = [
    (mkService "grafana" {
      port = 3005;
      domain = "grafana.${config.networking.domain}";
    })
  ];

  config = mkIf cfg.enable {
    sops.secrets = {
      grafana-secret-key = secret "grafana-secret-key";
      grafana-admin-password = secret "grafana-admin-password";
      grafana-oauth-secret = secret "grafana-oauth-secret";
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_addr = cfg.host;
          http_port = cfg.port;
          inherit (cfg) domain;
          root_url = "https://${cfg.domain}/";
        };

        security = {
          secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
          admin_password = "$__file{${config.sops.secrets.grafana-admin-password.path}}";
          cookie_secure = false;
        };

        auth.disable_login_form = false;

        "auth.generic_oauth" = {
          enabled = true;
          name = "kanidm";
          client_id = "grafana";
          client_secret = "$__file{${config.sops.secrets.grafana-oauth-secret.path}}";
          scopes = "openid profile email";
          auth_url = "${sso}/ui/oauth2";
          token_url = "${sso}/oauth2/token";
          api_url = "${sso}/oauth2/openid/grafana/userinfo";
          use_pkce = true;
          use_refresh_token = true;
          allow_sign_up = true;
          login_attribute_path = "preferred_username";
          role_attribute_path = "contains(grafana_role[*] || `[]`, 'Admin') && 'Admin' || 'Viewer'";
        };

        metrics.enabled = false;

        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
          check_for_plugin_updates = false;
        };
      };

      provision = {
        enable = true;

        dashboards.settings.providers = [
          {
            name = "fleet";
            folder = "Fleet";
            options.path = dashboards;
            allowUiUpdates = true;
            disableDeletion = true;
          }
        ];

        datasources.settings.datasources =
          optional services.prometheus.enable {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = local "prometheus";
            isDefault = true;
          }
          ++ optional services.loki.enable {
            name = "Loki";
            type = "loki";
            uid = "loki";
            url = local "loki";
          };
      };
    };
  };
}
