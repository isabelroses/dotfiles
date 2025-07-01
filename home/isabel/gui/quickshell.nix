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
    garden.programs.quickshell.package = pkgs.quickshell.overrideAttrs (oa: {
      buildInputs = oa.buildInputs or [ ] ++ [
        pkgs.kdePackages.qtimageformats
      ];
    });

    garden.packages = {
      quickshell = cfg.package;
    };
  };
}
