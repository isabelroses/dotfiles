{
  config,
  lib,
  pkgs,
  ...
}: let
  # modified from https://git.winston.sh/winston/deployment-flake/src/branch/main/modules/wakapi.nix
  cfg = config.services.wakapi;
  user = config.users.users.wakapi.name;
  group = config.users.groups.wakapi.name;

  settingsFormat = pkgs.formats.yaml {};
  inherit (lib) mkOption mkEnableOption mkPackageOption types mkIf optional mkMerge mkDoc mkDefault singleton;

  settingsFile = settingsFormat.generate "wakapi-settings" cfg.settings;

  userConfig = {
    users.users.wakapi = {
      inherit group;
      createHome = false;
      isSystemUser = true;
    };
    users.groups.wakapi = {};
  };

  serviceConfig = {
    systemd.services.wakapi = {
      description = "Wakapi (self-hosted WakaTime-compatible backend)";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      script = ''
        exec ${pkgs.wakapi}/bin/wakapi -config ${settingsFile}
      '';

      serviceConfig = {
        Environment = mkMerge [
          (mkIf (cfg.passwordSalt != null) "WAKAPI_PASSWORD_SALT=${cfg.passwordSalt}")
          (mkIf (cfg.smtpPassword != null) "WAKAPI_MAIL_SMTP_PASS=${cfg.smtpPassword}")
        ];
        EnvironmentFile = [
          (optional (cfg.passwordSaltFile != null) cfg.passwordSaltFile)
          (optional (cfg.smtpPasswordFile != null) cfg.smtpPasswordFile)
        ];

        User = user;
        Group = group;

        DynamicUser = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectoryMode = "0700";
        Restart = "always";
      };
    };

    services.wakapi.settings = {
      env = lib.mkDefault "production";
      inherit (cfg) db;
      server = {
        inherit (cfg) port;
      };
    };

    assertions = [
      {
        assertion = cfg.passwordSalt != null || cfg.passwordSaltFile != null;
        message = "Either `passwordSalt` or `passwordSaltFile` must be set.";
      }
      # {
      #   assertion = cfg.smtpPassword != null && cfg.smtpPasswordFile != null;
      #   message = "Both `smtpPassword` or `smtpPasswordFile` should not be set at the same time.";
      # }
    ];
  };

  databaseConfig = {
    services.postgresql = {
      enable = true;
      ensureDatabases = singleton cfg.settings.db.name;
      ensureUsers = singleton {
        name = cfg.settings.db.user;
        ensureDBOwnership = true;
      };
      authentication = ''
        host ${cfg.settings.db.name} ${cfg.settings.db.user} 127.0.0.1/32 trust
      '';
    };

    services.wakapi.settings.db = {
      dialect = "postgres";
    };

    systemd.services.wakapi = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
  };

  nginxConfig = mkIf cfg.nginx.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";

        enableACME = mkDefault true;
        forceSSL = mkDefault true;
      };
    };

    services.wakapi.settings.server = {
      public_url = mkDefault cfg.domain;
    };
  };
in {
  options.services.wakapi = {
    enable = mkEnableOption "Wakapi";
    package = mkPackageOption pkgs "wakapi" {};

    port = mkOption {
      type = types.int;
      default = 3000;
      description = ''
        The port to serve Wakapi on.
        This is used to configure nginx.
      '';
    };
    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The FQDN of the domain to serve Wakapi on.
        This is used to configure nginx.
      '';
    };

    db = {
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          The database host to use for Wakapi.
        '';
      };
      port = mkOption {
        type = types.int;
        default = 5432;
        description = ''
          The port to use for the database.
        '';
      };
      name = mkOption {
        type = types.str;
        default = "wakapi";
        description = ''
          The database name to use for Wakapi.
        '';
      };
      user = mkOption {
        type = types.str;
        default = "wakapi";
        description = ''
          The database user to use for Wakapi.
        '';
      };
      password = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The database password to use for Wakapi.
        '';
      };
    };

    nginx.enable = mkEnableOption "Wakapi Nginx";

    passwordSalt = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The password salt to use for Wakapi.
      '';
    };
    passwordSaltFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        The path to a file containing the password salt to use for Wakapi.
      '';
    };

    smtpPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The password used for the smtp mailed to used by Wakapi.
      '';
    };
    smtpPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        The path to a file containing the password for the smtp mailer used by Wakapi.
      '';
    };

    settings = mkOption {
      inherit (settingsFormat) type;
      default = {};
      description = mkDoc ''
        Settings for Wakapi.

        See [config.default.yml](https://github.com/muety/wakapi/blob/master/config.default.yml) for a list of all possible options.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    userConfig
    databaseConfig
    nginxConfig
    serviceConfig
  ]);
}
