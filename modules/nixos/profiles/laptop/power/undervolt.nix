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
    # temperature target on battery
    services.undervolt = {
      enable = config.garden.device.cpu == "intel";
      tempBat = 65; # deg C
      package = pkgs.undervolt;
    };
  };
}
