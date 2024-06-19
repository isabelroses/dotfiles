{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./greetd.nix
    ./sddm.nix
  ];

  options.modules.environment.loginManager = mkOption {
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
