{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr enum;
in
{
  imports = [
    ./greetd.nix
    ./sddm.nix
  ];

  options.garden.environment.loginManager = mkOption {
    type = nullOr (enum [
      "greetd"
      "sddm"
      "cosmic-greeter"
    ]);
    default = "greetd";
    description = "The login manager to be used by the system.";
  };
}
