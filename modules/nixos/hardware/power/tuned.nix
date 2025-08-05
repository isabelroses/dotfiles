{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.garden.profiles.laptop.enable {
    services = {
      tuned = {
        enable = true;

        # auto magically change the profile based on the battery charging state
        ppdSettings.main.battery_detection = true;
      };
    };
  };
}
