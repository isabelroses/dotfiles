{ config, ... }:
{
  services.tuned = {
    inherit (config.garden.profiles.laptop) enable;

    # auto magically change the profile based on the battery charging state
    ppdSettings.main.battery_detection = true;
  };
}
