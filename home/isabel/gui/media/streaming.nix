{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (config.programs.obs-studio) enable;
in
{
  config = lib.mkIf enable {
    garden.packages = {
      inherit (pkgs) chatterino7;
    };

    programs.obs-studio = {
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-multi-rtmp
        obs-move-transition
      ];
    };
  };
}
