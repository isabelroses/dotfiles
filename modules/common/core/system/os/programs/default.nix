{
  pkgs,
  lib,
  ...
}: {
  programs = {
    bash = {
      promptInit = ''
        eval "$(${lib.getExe pkgs.starship} init bash)"
      '';
    };
    # less pager
    # TODO: package moar for nix
    less.enable = true;

    fish.enable = true;
  };
}
