{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.garden.profiles.media.streaming.enable {
    garden.packages = {
      inherit (pkgs) chatterino7;
    };

    programs.obs-studio = {
      enable = true;
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
