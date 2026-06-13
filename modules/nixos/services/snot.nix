{
  lib,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.snot;
  rdomain = config.networking.domain;

  inherit (lib.modules) mkIf;
  inherit (self.lib) mkServiceOption;
in
{
  options.garden.services.snot = mkServiceOption "snot" {
    port = 3033;
    domain = "knot.${rdomain}";
  };

  config = mkIf cfg.enable {
    services = {
      snot = {
        enable = true;

        forgejoGroup = config.services.forgejo.group;

        settings = {
          hostname = cfg.domain;
          listen_addr = "${cfg.host}:${toString cfg.port}";
          owner_did = "did:plc:qxichs7jsycphrsmbujwqbfb";
          repo_root = config.services.forgejo.repositoryRoot;
          push_remote = "forgejo@${config.garden.services.forgejo.domain}";
          users."did:plc:qxichs7jsycphrsmbujwqbfb" = "isabel";
        };
      };

      postgresql.ensureUsers = lib.singleton { name = "snot"; };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          recommendedProxySettings = true;
          # /events is a websocket
          proxyWebsockets = true;
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
        };
      };
    };

    systemd.services.postgresql-setup.script = lib.mkAfter ''
      psql -d forgejo <<'EOF'
        GRANT CONNECT ON DATABASE forgejo TO "snot";
        ALTER DEFAULT PRIVILEGES FOR ROLE forgejo GRANT SELECT ON TABLES TO "snot";
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO "snot";
      EOF
    '';
  };
}
