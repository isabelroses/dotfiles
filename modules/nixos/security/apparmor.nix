{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe;
in
{
  services.dbus.apparmor = "disabled";

  # apparmor configuration
  security.apparmor = {
    enable = false;

    # whether to enable the AppArmor cache
    # in /var/cache/apparmore
    enableCache = true;

    # whether to kill processes which have an AppArmor profile enabled
    # but are not confined
    killUnconfinedConfinables = true;

    # packages to be added to AppArmor’s include path
    packages = [ pkgs.apparmor-profiles ];

    # apparmor policies
    policies = {
      "default_deny" = {
        state = "disable";
        profile = ''
          profile default_deny /** { }
        '';
      };

      "sudo" = {
        state = "disable";
        profile = ''
          ${getExe pkgs.sudo} {
            file /** rwlkUx,
          }
        '';
      };

      "nix" = {
        state = "disable";
        profile = ''
          ${getExe config.nix.package} {
            unconfined,
          }
        '';
      };
    };
  };
}
