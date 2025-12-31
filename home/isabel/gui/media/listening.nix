{
  lib,
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
      enabledExtensions = with spicePkgs.extensions; [
        shuffle
        copyToClipboard
        lastfm
        hidePodcasts
        adblock
        volumePercentage
        aiBandBlocker
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
