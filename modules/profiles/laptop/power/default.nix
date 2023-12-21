{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkDefault mkIf;
  inherit (config.modules) device;

  acceptedTypes = ["laptop" "hybrid"];
in {
  imports = [inputs.auto-cpufreq.nixosModules.default];

  config = mkIf (builtins.elem device.type acceptedTypes) {
    hardware.acpilight.enable = true;

    environment.systemPackages = with pkgs; [
      acpi
      powertop
      cpupower-gui
    ];

    programs.auto-cpufreq = {
      enable = true;
      settings = let
        MHz = x: x * 1000;
      in {
        battery = {
          governor = "powersave";
          scaling_min_freq = mkDefault (MHz 1200);
          scaling_max_freq = mkDefault (MHz 1800);
          turbo = "never";
        };
        charger = {
          governor = "performance";
          scaling_min_freq = mkDefault (MHz 1800);
          scaling_max_freq = mkDefault (MHz 3800);
          turbo = "auto";
        };
      };
    };

    services = {
      # handle ACPI events
      acpid.enable = true;

      # a very cool user-selected power profiles helping my system not die 5 mins into my lecture
      power-profiles-daemon.enable = true;

      # temperature target on battery
      undervolt = {
        tempBat = 65; # deg C
        package = pkgs.undervolt;
      };

      /*
      # superior power management
      auto-cpufreq.enable = true;

      auto-cpufreq.settings = {
        battery = {
          governor = "powersave";
          scaling_min_freq = mkDefault (MHz 1200);
          scaling_max_freq = mkDefault (MHz 1800);
          turbo = "never";
        };
        charger = {
          governor = "performance";
          scaling_min_freq = mkDefault (MHz 1800);
          scaling_max_freq = mkDefault (MHz 3000);
          turbo = "auto";
        };
      };
      */

      # DBus service that provides power management support to applications.
      upower = {
        enable = true;
        percentageLow = 15;
        percentageCritical = 5;
        percentageAction = 3;
        criticalPowerAction = "Hibernate";
      };
    };

    boot = {
      kernelModules = ["acpi_call"];
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
        cpupower
      ];
    };
  };
}
