{ lib, config, ... }:
let
  inherit (lib) mkIf;
  prof = config.garden.profiles;
in
{
  config = mkIf prof.laptop.enable {
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "suspend-then-hibernate";
    };

    # https://wiki.debian.org/Suspend#Disable_suspend_and_hibernation
    systemd.sleep.settings.Sleep = mkIf prof.headless.enable {
      AllowSuspend = false;
      AllowHibernation = false;
      AllowSuspendThenHibernate = false;
      AllowHybridSleep = false;
    };
  };
}
