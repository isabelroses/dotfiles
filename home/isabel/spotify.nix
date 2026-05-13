{
  pkgs,
  config,
  inputs,
  inputs',
  ...
}:
let
  spicePkgs = inputs'.spicetify.legacyPackages;
in
{
  imports = [ inputs.spicetify.homeManagerModules.spicetify ];

  config.programs.spicetify = {
    inherit (config.garden.profiles.media.watching) enable;

    spotifyPackage =
      if pkgs.stdenv.hostPlatform.isLinux then
        pkgs.spotify.override { ffmpeg_4 = pkgs.ffmpeg; }
      else
        pkgs.spotify;

    colorScheme = "CatppuccinMocha";
    theme = spicePkgs.themes.text;

    enabledExtensions = with spicePkgs.extensions; [
      shuffle
      copyToClipboard
      # lastfm
      hidePodcasts
      adblock
      volumePercentage
      aiBandBlocker
    ];
  };
}
