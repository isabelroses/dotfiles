{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkForce concatStringsSep;

  avoid = concatStringsSep "|" [
    "(h|H)yprland"
    "sway"
    "Xwayland"
    "cryptsetup"
    "dbus-.*"
    "gpg-agent"
    "greetd"
    "ssh-agent"
    ".*qemu-system.*"
    "sddm"
    "sshd"
    "systemd"
    "systemd-.*"
    "wezterm"
    "kitty"
    "bash"
    "zsh"
    "fish"
    "n?vim"
    "akkoma"
  ];

  prefer = concatStringsSep "|" [
    "Web Content"
    "Isolated Web Co"
    "firefox.*"
    "chrom(e|ium).*"
    "electron"
    "dotnet"
    ".*.exe"
    "java.*"
    "pipewire(.*)"
    "nix"
    "npm"
    "node"
    "pipewire(.*)"
  ];
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    # https://dataswamp.org/~solene/2022-09-28-earlyoom.html
    # avoid the linux kernel from locking itself when we're putting too much strain on the memory
    # this helps avoid having to shut down forcefully when we OOM
    services = {
      earlyoom = {
        enable = true;
        enableNotifications = true; # annoying, but we want to know what's killed

        reportInterval = 0;
        freeSwapThreshold = 5;
        freeSwapKillThreshold = 2;
        freeMemThreshold = 5;
        freeMemKillThreshold = 2;

        extraArgs = [
          "-g"
          "--avoid"
          "'^(${avoid})$'" # things that we want to avoid killing
          "--prefer"
          "'^(${prefer})$'" # things we want to remove fast
        ];

        # we should ideally write the logs into a designated log file; or even better, to the journal
        # for now we can hope this echo sends the log to somewhere we can observe later
        killHook = pkgs.writeShellScript "earlyoom-kill-hook" ''
          echo "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed"
        '';
      };

      systembus-notify.enable = mkForce true;
    };
  };
}
