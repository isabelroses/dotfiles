{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) attrValues;
in
{
  config.garden.programs = {
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
