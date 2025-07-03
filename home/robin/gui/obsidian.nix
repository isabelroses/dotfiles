{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) attrValues mkIf;
in
{
  garden.packages = mkIf config.garden.profiles.workstation.enable {
    obsidian = pkgs.symlinkJoin {
      name = "obsidian-wrapped";
      paths = attrValues {
        inherit (pkgs)
          # for the pandoc plugin
          pandoc

          # for the obsidian-git plugin
          git
          git-lfs
          ;
      };
      meta.mainProgram = pkgs.obsidian.meta.mainProgram;
    };
  };
}
