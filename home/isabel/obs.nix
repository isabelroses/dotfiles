{ pkgs, config, ... }:
{
  programs.obs-studio = {
    inherit (config.garden.profiles.media.streaming) enable;

    package = pkgs.pkgsCuda.obs-studio;

    plugins = with pkgs.pkgsCuda.obs-studio-plugins; [
      wlrobs
      obs-multi-rtmp
      obs-pipewire-audio-capture

      (obs-move-transition.overrideAttrs (_: {
        version = "3.2.1-unstable-2026-10-04";

        src = pkgs.fetchFromGitHub {
          owner = "exeldro";
          repo = "obs-move-transition";
          rev = "64590490d87d93cc03baf0b35b90709468d9fb03";
          hash = "sha256-GOXNUwA2ASzDHMjsXSdUYQzqOtEBwmrr3oz5TXueKjY=";
        };
      }))
    ];
  };
}
