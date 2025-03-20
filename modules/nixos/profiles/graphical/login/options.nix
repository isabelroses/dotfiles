{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkOptionDefault;
  inherit (lib.types) nullOr enum;
  inherit (self.lib.validators) hasProfile;
in
{
  options.garden.environment.loginManager = mkOption {
    type = nullOr (enum [
      "greetd"
      "sddm"
      "cosmic-greeter"
    ]);
    description = "The login manager to be used by the system.";
  };

  config = {
    garden.environment.loginManager = mkOptionDefault (
      if (hasProfile config [ "graphical" ]) then "greetd" else null
    );
  };
}
