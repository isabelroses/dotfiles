{
  config,
  lib,
  pkgs,
  ...
} @ args:
with lib; let
  device = config.modules.device;

  MHz = x: x * 1000;
in {
  config = mkIf (device.type == "laptop" || device.type == "hybrid") {
    hardware.acpilight.enable = true;

    environment.systemPackages = with pkgs; [
      acpi
      powertop
    ];

    services = {
      # superior power management
      auto-cpufreq.enable = true;

      power-profiles-daemon.enable = true;

      # temperature target on battery
      undervolt = {
        tempBat = 65; # deg C
        package = pkgs.undervolt;
      };

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

      # DBus service that provides power management support to applications.
      upower = {
        enable = true;
        percentageLow = 15;
        percentageCritical = 5;
        percentageAction = 3;
        criticalPowerAction = "Hibernate";
      };

      udev.extraRules = let
        inherit (import ./plugged.nix args) plugged unplugged;
      in ''
        # start/stop services on power (un)plug
        SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${plugged}"
        SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${unplugged}"
      '';
    };
    boot = {
      kernelModules = ["acpi_call"];
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
        cpupower
        pkgs.cpupower-gui
      ];
    };
  };
}
