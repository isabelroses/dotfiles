{ pkgs, config, ... }:
{
  programs.obs-studio = {
    inherit (config.garden.profiles.media.streaming) enable;

    package = pkgs.pkgsCuda.obs-studio;

    plugins = with pkgs.pkgsCuda.obs-studio-plugins; [
      wlrobs
      obs-multi-rtmp
      obs-move-transition
      obs-pipewire-audio-capture
    ];
  };
}
