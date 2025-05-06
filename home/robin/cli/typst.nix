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
  config = mkIf config.garden.programs.notes.enable {
    garden.packages = {
      inherit (pkgs) typst;
    };
  };
}
