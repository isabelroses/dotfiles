{
  lib,
  self,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs mergeAttrsList;
  inherit (lib.modules) mkIf;
  inherit (self.lib.programs) mkProgram;

  cfg = config.garden.programs;
in
{
  options.garden.programs = {
    cosmic-files = mkProgram pkgs "cosmic-files" {
      enable.default = config.garden.programs.gui.enable;
    };

    dolphin = mkProgram pkgs "dolphin" {
      package.default = pkgs.kdePackages.dolphin;
    };

    nemo = mkProgram pkgs "nemo" {
      package.default = pkgs.nemo-with-extensions;
    };
  };

  config = mkIf (cfg.gui.enable && osConfig.garden.meta.isWM) {
    garden.packages = mergeAttrsList [
      (optionalAttrs cfg.cosmic-files.enable { inherit (cfg.cosmic-files) package; })

      (optionalAttrs cfg.nemo.enable {
        inherit (cfg.nemo) package;
        inherit (pkgs) nemo-fileroller nemo-emblems;
      })

      (optionalAttrs cfg.dolphin.enable { inherit (cfg.dolphin) package; })
    ];
  };
}
