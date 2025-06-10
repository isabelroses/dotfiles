{ lib, config, ... }:
let
  inherit (lib) mkIf;
  prof = config.garden.profiles;
in
{
  config = mkIf prof.laptop.enable {
    services.logind = {
      lidSwitch = "ignore";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "ignore";
      powerKey = "suspend-then-hibernate";
    };

    # https://wiki.debian.org/Suspend#Disable_suspend_and_hibernation
    systemd.sleep.extraConfig = mkIf prof.headless.enable ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };
}
