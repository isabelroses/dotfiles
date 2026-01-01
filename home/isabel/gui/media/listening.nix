{
  lib,
  pkgs,
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib) mkIf;

  spicePkgs = inputs'.spicetify.legacyPackages;
in
{
  imports = [ inputs.spicetify.homeManagerModules.spicetify ];

  config = mkIf config.garden.profiles.media.watching.enable {
    programs.spicetify = {
      enable = true;

      spotifyPackage =
        if pkgs.stdenv.hostPlatform.isLinux then
          pkgs.spotify.override { ffmpeg_4 = pkgs.ffmpeg; }
        else
          pkgs.spotify;

      colorScheme = "mocha";
      theme = spicePkgs.themes.catppuccin;

      enabledExtensions = with spicePkgs.extensions; [
        shuffle
        copyToClipboard
        lastfm
        hidePodcasts
        adblock
        volumePercentage
        aiBandBlocker
      ];
    };
  };
}
