{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.programs.git.enable {
    garden.packages = {
      inherit (pkgs) cocogitto;
    };
  };
}
