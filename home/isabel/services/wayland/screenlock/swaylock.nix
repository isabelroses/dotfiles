{
  lib,
  pkgs,
  osConfig,
  defaults,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland;
in
{
  config = mkIf (isWayland osConfig && defaults.screenLocker == "swaylock") {
    home.packages = [ pkgs.swaylock-effects ];

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;

      settings = {
        ignore-empty-password = true;
        show-failed-attempts = true;
        clock = true;
        indicator-radius = 120;
        indicator-thickness = 20;
        line-uses-ring = true;
        font = osConfig.garden.style.font.name;
        font-size = 32;
      };
    };
  };
}
