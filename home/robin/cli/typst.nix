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
  config = mkIf config.garden.profiles.workstation.enable {
    garden.packages = {
      inherit (pkgs) typst;
    };
  };
}
