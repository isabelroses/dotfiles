{config, ...}: {
  config = {
    # automatically optimize /nix/store by removing hard links
    nix.settings = {
      # Make builds run with a low priority, keeping the system fast
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;

      nix.gc.dates = "Mon *-*-* 03:00";

      # execute builds inside cgroups
      use-cgroups = true;

      optimise = {
        automatic = true;
        dates = ["04:00"];
      };

      extra-platforms = config.boot.binfmt.emulatedSystems;
    };

    system.autoUpgrade.enable = false;
  };
}
