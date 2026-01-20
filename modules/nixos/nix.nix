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
