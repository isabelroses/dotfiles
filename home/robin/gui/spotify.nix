{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  inherit (config.garden.profiles.graphical) enable;
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  config.programs.spicetify = mkIf enable {
    enable = true;

    colorScheme = "fall";
  };
}
