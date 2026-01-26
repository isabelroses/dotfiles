{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.radarr;
in
{
  options.garden.services.radarr = mkServiceOption "radarr" {
    port = 3021;
  };

  config = mkIf config.garden.services.radarr.enable {
    services.radarr = {
      inherit (cfg) enable;
      group = "media";
      dataDir = "/srv/storage/radarr";
      inherit (config.garden.services.arr) openFirewall;
      settings.server.port = cfg.port;
    };

    systemd.services.radarr.serviceConfig = {
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      # ProtectSystem = "strict";
      ProtectHome = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      UMask = "0022";
      ProtectHostname = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      LockPersonality = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@debug"
        "~@mount"
      ];
    };

  };
}
