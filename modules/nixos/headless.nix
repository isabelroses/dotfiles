{ lib, config, ... }:
let
  inherit (lib) mkIf mapAttrs mkForce;
in
{
  config = mkIf config.garden.profiles.headless.enable {
    # print the URL instead on servers
    environment.variables.BROWSER = "echo";

    # we don't need fonts on a server
    # since there are no fonts to be configured outside the console
    fonts = mapAttrs (_: mkForce) {
      packages = [ ];
      fontDir.enable = false;
      fontconfig.enable = false;
    };

    # a headless system should not mount any removable media without explicit
    # user action
    services.udisks2.enable = lib.modules.mkForce false;

    xdg = mapAttrs (_: mkForce) {
      sounds.enable = false;
      mime.enable = false;
      menus.enable = false;
      icons.enable = false;
      autostart.enable = false;
    };

    # https://github.com/numtide/srvos/blob/main/nixos/server/default.nix
    systemd = {
      # given that our systems are headless, emergency mode is useless.
      # we prefer the system to attempt to continue booting so
      # that we can hopefully still access it remotely.
      enableEmergencyMode = false;

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      watchdog = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 10s.
        # If the hardware watchdog does not get a signal for 20s,
        # it will forcefully reboot the system.
        runtimeTime = "20s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        rebootTime = "30s";
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };
  };
}
