{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services;
in {
  config = mkIf cfg.miniflux.enable {
    # https://github.com/Gerg-L/nixos/blob/master/hosts/gerg-desktop/services/miniflux.nix

    systemd.services = {
      miniflux = {
        description = "Miniflux service";
        wantedBy = ["multi-user.target"];
        requires = ["miniflux-dbsetup.service"];
        after = ["network.target" "postgresql.service" "miniflux-dbsetup.service"];
        script = lib.getExe' pkgs.miniflux "miniflux";

        serviceConfig = {
          User = "miniflux";
          RuntimeDirectory = "miniflux";
          RuntimeDirectoryMode = "0770";
          EnvironmentFile = config.sops.secrets.miniflux-env.path;

          # Hardening
          CapabilityBoundingSet = [""];
          DeviceAllow = [""];
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = ["@system-service" "~@privileged"];
          UMask = "0077";
        };

        environment = {
          BASE_URL = "https://flux.isabelroses.com";
          LISTEN_ADDR = "/run/miniflux/miniflux.sock";
          DATABASE_URL = "user=miniflux host=/run/postgresql dbname=miniflux";
          RUN_MIGRATIONS = "1";
          CREATE_ADMIN = "1";
        };
      };
      miniflux-dbsetup = {
        description = "Miniflux database setup";
        requires = ["postgresql.service"];
        after = ["network.target" "postgresql.service"];
        script = ''
          ${lib.getExe' config.services.postgresql.package "psql"} "miniflux" -c "CREATE EXTENSION IF NOT EXISTS hstore"
        '';
        serviceConfig = {
          Type = "oneshot";
          User = config.services.postgresql.superUser;
        };
      };
    };
    users = {
      groups.miniflux = {
        gid = 377;
      };
      users = {
        miniflux = {
          group = "miniflux";
          extraGroups = ["postgres"];
          isSystemUser = true;
          uid = 377;
        };
        ${config.services.nginx.user}.extraGroups = ["miniflux"];
      };
    };
  };
}
