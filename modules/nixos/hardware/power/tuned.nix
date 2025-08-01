{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf getExe';

  tuned-adm = getExe' config.services.tuned.package "tuned-adm";
in
{
  config = mkIf config.garden.profiles.laptop.enable {
    services = {
      tuned.enable = true;

      udev.extraRules = ''
        SUBSYSTEM=="power_supply", ATTR{status}=="Charging", RUN+="${tuned-adm} profile battery"
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", RUN+="${tuned-adm} profile balanced"
      '';
    };
  };
}
