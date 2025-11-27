{ pkgs, ... }:
{
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
}
