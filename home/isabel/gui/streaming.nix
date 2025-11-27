{ pkgs, ... }:
{
  programs.obs-studio = {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-multi-rtmp
      obs-move-transition
    ];
  };
}
