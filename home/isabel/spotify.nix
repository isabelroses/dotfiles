{
  config,
  inputs,
  ...
}:
let
  spicePkgs = inputs.spicetify.packages;
in
{
  imports = [ inputs.spicetify.homeManagerModules.spicetify ];

  config.programs.spicetify = {
    inherit (config.garden.profiles.media.watching) enable;

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
