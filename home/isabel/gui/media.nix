{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) optionalAttrs mergeAttrsList;

  streaming = config.programs.obs-studio.enable;
  watching = config.garden.profiles.graphical.enable && pkgs.stdenv.hostPlatform.isLinux;
in
{
  garden.packages = mergeAttrsList [
    (optionalAttrs streaming {
      inherit (pkgs) chatterino7;
    })

    (lib.optionalAttrs watching {
      inherit (pkgs) syncplay yt-dlp ffmpeg;
    })
  ];

  programs = {
    mpv.enable = watching;

    obs-studio = {
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
