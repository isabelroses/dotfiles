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
  config = mkIf (config.garden.profiles.graphical.enable &&
    config.garden.profiles.workstation.enable &&
    config.garden.programs.defaults.fileManager == "cosmic-files") {
    garden.packages = {
      inherit (pkgs) cosmic-files;
    };
  };
}
