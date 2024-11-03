{ pkgs, config, ... }:
{
  # temperature target on battery
  services.undervolt = {
    enable = config.garden.device.cpu == "intel";
    tempBat = 65; # deg C
    package = pkgs.undervolt;
  };
}
