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
    less.enable = true;

    fish.enable = true;
  };
}
