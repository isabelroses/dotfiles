let
  # this is a forced SSL template for Nginx
  # returns the attribute set with our desired settings
  ssl = domain: {
    quic = true;
    forceSSL = true;
    enableACME = false;
    useACMEHost = domain;
  };

  systemd = {
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateIPC = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RestrictNamespaces = "uts ipc pid user cgroup";
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" ];
    UMask = "0077";
  };

  xdg = import ./xdg.nix;
  textmate = import ./textmate.nix;
in
{
  inherit
    ssl
    systemd
    xdg
    textmate
    ;
}
