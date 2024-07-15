{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland;
  inherit (lib.lists) optionals;
in
{
  config = mkIf (isWayland osConfig) {
    home.packages = [
      pkgs.swappy # used for screenshot area selection
      pkgs.wl-gammactl
    ] ++ optionals osConfig.garden.system.sound.enable [ pkgs.pwvucontrol ];
  };
}
