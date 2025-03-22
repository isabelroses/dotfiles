{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  garden.packages = mkIf config.programs.git.enable {
    inherit (pkgs)
      # gist # manage github gists
      # act # local github actions - littrally does not work
      # gitflow # Extend git with the Gitflow branching model
      cocogitto # git helpers
      ;
  };
}
