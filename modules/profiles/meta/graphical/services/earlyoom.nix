{ pkgs, ... }:
{
  # https://dataswamp.org/~solene/2022-09-28-earlyoom.html
  # avoid the linux kernel from locking itself when we're putting too much strain on the memory
  # this helps avoid having to shut down forcefully when we OOM
  services.earlyoom = {
    enable = true;
    enableNotifications = true; # annoying, but we want to know what's killed
    freeSwapThreshold = 2;
    freeMemThreshold = 2;
    extraArgs = [
      "-g"
      "--avoid 'Hyprland|soffice|soffice.bin|firefox)$'" # things we want to not kill
      "--prefer '^(electron|.*.exe)$'" # I wish we could kill electron permanently
    ];

    # we should ideally write the logs into a designated log file; or even better, to the journal
    # for now we can hope this echo sends the log to somewhere we can observe later
    killHook = pkgs.writeShellScript "earlyoom-kill-hook" ''
      echo "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed"
    '';
  };
}
