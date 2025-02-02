{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkIf;
in
{
  config.garden.programs = mkIf config.garden.programs.notes.enable {
    obsidian.runtimeInputs = attrValues {
      inherit (pkgs)
        # for the pandoc plugin
        pandoc

        # for the obsidian-git plugin
        git
        git-lfs
        ;
    };
  };
}
