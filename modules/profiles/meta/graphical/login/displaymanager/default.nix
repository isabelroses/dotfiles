{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./greetd.nix
    ./sddm.nix
  ];

  options.garden.environment.loginManager = mkOption {
    type = types.nullOr (
      types.enum [
        "greetd"
        "sddm"
      ]
    );
    default = "greetd";
    description = "The login manager to be used by the system.";
  };
}
