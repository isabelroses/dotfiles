{
  config,
  pkgs,
  ...
}: {
  services.dbus.apparmor = "disabled";

  # apparmor configuration
  security.apparmor = {
    enable = true;

    # whether to enable the AppArmor cache
    # in /var/cache/apparmore
    enableCache = true;

    # whether to kill processes which have an AppArmor profile enabled
    # but are not confined
    killUnconfinedConfinables = true;

    # packages to be added to AppArmor’s include path
    packages = [pkgs.apparmor-profiles];

    # apparmor policies
    policies = {
      "default_deny" = {
        enforce = false;
        enable = false;
        profile = ''
          profile default_deny /** { }
        '';
      };

      "sudo" = {
        enforce = false;
        enable = false;
        profile = ''
          ${pkgs.sudo}/bin/sudo {
            file /** rwlkUx,
          }
        '';
      };

      "nix" = {
        enforce = false;
        enable = false;
        profile = ''
          ${config.nix.package}/bin/nix {
            unconfined,
          }
        '';
      };
    };
  };
}
