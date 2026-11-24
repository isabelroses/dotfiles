{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf;

  cfg = config.garden.services.sonarr;
in
{
  imports = [
    (mkService "sonarr" {
      port = 3020;
      host = "0.0.0.0";
    })
  ];

  config = mkIf config.garden.services.sonarr.enable {
    services.sonarr = {
      inherit (cfg) enable;
      group = "media";
      dataDir = "/srv/storage/sonarr";
      settings.server = {
        inherit (cfg) port;
        bindaddress = cfg.host;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.sonarr.serviceConfig = {
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
      # group-writable for hardlinks
      UMask = lib.mkForce "0002";
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
