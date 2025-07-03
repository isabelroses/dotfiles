{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.garden.programs.quickshell;
in
{
  config = lib.mkIf config.garden.programs.quickshell.enable {
    garden.programs.quickshell.package = pkgs.symlinkJoin {
      name = "quickshell-wrapped";
      paths = [
        pkgs.quickshell
        pkgs.kdePackages.qtimageformats
      ];
    };

    garden.packages = {
      quickshell = cfg.package;
    };
  };
}
