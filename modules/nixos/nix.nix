{config, ...}: {
  config = {
    nix = {
      gc.dates = "Mon *-*-* 03:00";

      # automatically optimize /nix/store by removing hard links
      optimise = {
        automatic = true;
        dates = ["04:00"];
      };

      # Make builds run with a low priority, keeping the system fast
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;

      settings = {
        use-cgroups = true; # execute builds inside cgroups

        extra-platforms = config.boot.binfmt.emulatedSystems;
      };
    };

    system.autoUpgrade.enable = false;
  };
}
