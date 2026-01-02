{
  lib,
  config,
  options,
  modulesPath,
  ...
}:
let
  lixModuleMerged = lib.pathExists "${modulesPath}/programs/lix.nix";
  nixDaemonCfg = config.systemd.services.nix-daemon;
in
{
  config = lib.mkMerge [
    {
      nix = {
        # set the nix store to clean every Monday at 3am
        gc.dates = "Mon *-*-* 03:00";

        # automatically optimize /nix/store by removing hard links
        optimise = {
          automatic = true;
          dates = [ "04:00" ];
        };

        # Make builds run with a low priority, keeping the system fast
        # daemonCPUSchedPolicy = "idle";
        # daemonIOSchedClass = "idle";
        # daemonIOSchedPriority = 7;

        # set the build dir to /var/tmp to avoid issues on tmpfs
        # https://github.com/NixOS/nixpkgs/issues/293114#issuecomment-2663470083
        settings.build-dir = "/var/tmp";
      };
    }

    # https://github.com/NixOS/nixpkgs/pull/469067
    (lib.mkIf (!lixModuleMerged) {
      systemd.services."nix-daemon@" = {
        path = lib.subtractLists (options.systemd.services.type.getSubOptions "").path.value nixDaemonCfg.path;
        environment = lib.filterAttrs (n: _v: n != "PATH") nixDaemonCfg.environment;
        inherit (nixDaemonCfg) serviceConfig unitConfig;
        stopIfChanged = false;
        restartIfChanged = false;
      };

      # stc can't restart socket units. it can only reload them, but reloading sockets is in invalid operation!
      systemd.services.lix-daemon-socket-permissions = {
        overrideStrategy = "asDropin";
        inherit (nixDaemonCfg) restartTriggers;
        stopIfChanged = false;
      };
    })
  ];
}
