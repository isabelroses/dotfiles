{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types mapAttrs;

  rdomain = "isabelroses.com";

  mkServiceOption = name: {
    port ? 0,
    host ? "127.0.0.1",
    domain ? rdomain,
    extraConfig ? {},
  }:
    {
      enable = mkEnableOption "Enable the ${name} service";

      host = mkOption {
        type = types.str;
        default = host;
        description = "The host for ${name} service";
      };

      port = mkOption {
        type = types.port;
        default = port;
        description = "The port for ${name} service";
      };

      domain = mkOption {
        type = types.str;
        default = domain;
        description = "Domain name for the ${name} service";
      };
    }
    // extraConfig;
in {
  options.modules.services =
    mapAttrs mkServiceOption {
      vaultwarden = {
        port = 8222;
        domain = "vault.${rdomain}";
      };

      isabelroses-website = {
        port = 3000;
      };

      blahaj = {};

      vikunja = {
        domain = "todo.${rdomain}";
        port = 3456;
      };

      kanidm = {
        port = 8443;
        domain = "sso.${rdomain}";
      };

      mailserver.domain = "mail.${rdomain}";
    }
    // {
      dev = mapAttrs mkServiceOption {
        vscode-server = {};
        cyberchef = {};

        forgejo = {
          port = 7000;
          domain = "git.${rdomain}";
        };

        atuin = {
          port = 43473;
          domain = "atuin.${rdomain}";
        };

        plausible = {
          port = 2100;
          domain = "p.${rdomain}";
        };

        wakapi = {
          port = 15912;
          domain = "wakapi.${rdomain}";
        };
      };

      # system monitoring services
      monitoring = mapAttrs mkServiceOption {
        prometheus = {
          port = 9100;
        };

        grafana = {
          port = 3100;
          host = "0.0.0.0";
          domain = "graph.${rdomain}";
        };

        loki = {
          port = 3030;
        };

        uptime-kuma = {
          port = 3500;
          domain = "status.${rdomain}";
        };
      };

      # media services
      media = mapAttrs mkServiceOption {
        akkoma = {
          domain = "akko.${rdomain}";
        };

        searxng = {
          port = 80;
          domain = "search.${rdomain}";
        };

        matrix = {
          port = 8008;
          domain = "matrix.${rdomain}";
        };

        jellyfin = {
          port = 8096;
          domain = "tv.${rdomain}";
        };

        photoprism = {
          port = 2342;
          host = "0.0.0.0";
          domain = "photos.${rdomain}";
        };

        nextcloud = {
          domain = "cloud.${rdomain}";
        };
      };

      # databases
      database = mapAttrs mkServiceOption {
        influxdb = {};
        mysql = {};
        postgresql = {};
        redis = {};

        mongodb = {
          host = "0.0.0.0";
        };
      };

      # networking services
      networking = mapAttrs mkServiceOption {
        nginx = {};
        cloudflared = {};

        headscale = {
          port = 8085;
          host = "0.0.0.0";
          domain = "hs.${rdomain}";
        };
      };
    };
}
