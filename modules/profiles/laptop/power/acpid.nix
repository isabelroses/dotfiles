{ pkgs, config, ... }:
{
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

}
