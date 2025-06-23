{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  inherit (config.garden.profiles.graphical) enable;
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  config.programs.spicetify = mkIf enable {
    enable = true;

    colorScheme = "fall";

    theme = {
      name = "evergarden";
      src = pkgs.fetchFromGitHub {
        owner = "everviolet";
        repo = "spicetify";
        rev = "d37d8ce00ba544f95d42e92eb8c4c23048d39720";
        hash = "sha256-yt+swt9HjR9maO6atz/It7dzxStEJpykBgwgqeBpn/8=";
        postFetch = ''
          cd $out
          find evergarden -mindepth 1 -maxdepth 1 -exec mv -i -- {} . \;
          find . -depth -maxdepth 1 -type d -empty -exec rmdir {} \;
        '';
      };
    };
  };
}
