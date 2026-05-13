{ pkgs, config, ... }:
{
  programs.obs-studio = {
    inherit (config.garden.profiles.media.streaming) enable;

    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-multi-rtmp
      obs-move-transition
    ];
  };
}
