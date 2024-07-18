{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland;
in
{
  config = mkIf (isWayland osConfig) {
    home.packages = [
      pkgs.swappy # used for screenshot area selection
      pkgs.wl-gammactl
    ];
  };
}
