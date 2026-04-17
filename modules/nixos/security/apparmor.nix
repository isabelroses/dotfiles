{ pkgs, ... }:
{
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
    packages = [ pkgs.apparmor-profiles ];
  };
}
