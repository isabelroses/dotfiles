{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  rdomain = config.networking.domain;

  cfg = config.garden.services.matrix;

  bindAddress = "::1";
  serverConfig."m.server" = "${config.services.matrix-synapse.settings.server_name}:443";
  clientConfig = {
    "m.homeserver".base_url = "https://${cfg.domain}";
  };

  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    add_header 'Referrer-Policy' 'origin-when-cross-origin';
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  options.garden.services.matrix = mkServiceOption "matrix" {
    port = 8008;
    domain = "matrix.${rdomain}";
  };

  config = mkIf cfg.enable {
    age.secrets.matrix = mkSecret {
      file = "matrix/env";
      owner = "matrix-synapse";
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    garden.services = {
      nginx.enable = true;
      postgresql.enable = true;
    };

    services = {
      postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';

      nginx.virtualHosts.${rdomain} = {
        locations = {
          "= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
          "= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
          "/_matrix".proxyPass = "http://[${bindAddress}]:${toString cfg.port}";
          "/_synapse/client".proxyPass = "http://[${bindAddress}]:${toString cfg.port}";
        };
        serverAliases = [ "${cfg.domain}" ];
      } // template.ssl rdomain;

      matrix-synapse = {
        enable = true;

        extraConfigFiles = [ config.age.secrets.matrix.path ];
        settings = {
          withJemalloc = true;
          enable_registration = true;
          registration_requires_token = true;

          bcrypt_rounds = 14;

          # Don't report usage statistics, i really don't care
          report_stats = false;

          # domain for the server
          server_name = rdomain;
          public_baseurl = "https://${rdomain}";

          # media
          media_retention.remote_media_lifetime = "30d";
          max_upload_size = "100M";
          url_preview_enabled = true;
          url_preview_ip_range_blacklist = [
            "127.0.0.0/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "100.64.0.0/10"
            "192.0.0.0/24"
            "169.254.0.0/16"
            "192.88.99.0/24"
            "198.18.0.0/15"
            "192.0.2.0/24"
            "198.51.100.0/24"
            "203.0.113.0/24"
            "224.0.0.0/4"
            "::1/128"
            "fe80::/10"
            "fc00::/7"
            "2001:db8::/32"
            "ff00::/8"
            "fec0::/10"
          ];

          # db
          database = {
            name = "psycopg2";
            args = {
              host = "/run/postgresql";
              user = "matrix-synapse";
              database = "matrix-synapse";
              cp_min = 5;
              cp_max = 10;
            };
          };

          # listener configuration
          listeners = [
            {
              inherit (cfg) port;
              bind_addresses = [ "${bindAddress}" ];
              resources = [
                {
                  names = [
                    "client"
                    "federation"
                  ];
                  compress = true;
                }
              ];
              tls = false;
              type = "http";
              x_forwarded = true;
            }
          ];

          logConfig = ''
            version: 1

            # In systemd's journal, loglevel is implicitly stored, so let's omit it
            # from the message text.
            formatters:
                journal_fmt:
                    format: '%(name)s: [%(request)s] %(message)s'

            filters:
                context:
                    (): synapse.util.logcontext.LoggingContextFilter
                    request: ""

            handlers:
                journal:
                    class: systemd.journal.JournalHandler
                    formatter: journal_fmt
                    filters: [context]
                    SYSLOG_IDENTIFIER: synapse

            root:
                level: WARNING
                handlers: [journal]

            disable_existing_loggers: False
          '';
        };
      };
    };
  };
}
