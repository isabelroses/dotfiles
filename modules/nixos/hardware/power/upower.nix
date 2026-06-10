{ config, ... }:
{
  # DBus service that provides power management support to applications.
  services.upower = {
    enable = config.garden.profiles.laptop.enable;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };
}
