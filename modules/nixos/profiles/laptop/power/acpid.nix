{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;
in
{
  config = mkIf (hasProfile config [ "laptop" ]) {
    # pretty much handled by brightnessctl
    hardware.acpilight.enable = false;

    # handle ACPI events
    services.acpid.enable = true;

    garden.packages = { inherit (pkgs) acpi powertop; };

    boot = {
      kernelModules = [ "acpi_call" ];
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
        cpupower
      ];
    };
  };
}
