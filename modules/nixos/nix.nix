{ lib, config, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  nix = {
    gc = {
      automatic = mkForce (!config.programs.nh.clean.enable);
      dates = "Mon *-*-* 03:00";
    };

    # automatically optimize /nix/store by removing hard links
    optimise = {
      automatic = true;
      dates = [ "04:00" ];
    };

    # Make builds run with a low priority, keeping the system fast
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;

    settings = {
      # the defaults to false even if the experimental feature is enabled
      # so we need to enable it here, this is also only available on linux
      # and the option is explicitly removed on darwin so we have to have this here
      use-cgroups = true;

      extra-platforms = config.boot.binfmt.emulatedSystems;
    };
  };

  system.autoUpgrade.enable = false;
}
