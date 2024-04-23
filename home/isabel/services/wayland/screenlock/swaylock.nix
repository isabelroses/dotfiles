{
  lib,
  pkgs,
  osConfig,
  defaults,
  ...
}: let
  inherit (lib) mkIf isWayland;
in {
  config = mkIf (isWayland osConfig && defaults.screenLocker == "swaylock") {
    home.packages = with pkgs; [swaylock-effects];

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
        font = "CommitMono";
        font-size = 32;
      };
    };
  };
}
