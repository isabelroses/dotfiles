{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    mkEnableOption
    makeBinPath
    ;
  inherit (lib.types) listOf package;
  inherit (self.lib) mkProgram;

  cfg = config.garden.programs;
in
{
  options.garden.programs = {
    notes.enable = mkEnableOption "enable notes programs";

    obsidian = mkProgram pkgs "obsidian" {
      enable.default = cfg.notes.enable && config.garden.profiles.graphical.enable;

      package.default = pkgs.symlinkJoin {
        name = "obsidian-wrapped";

        paths = [ pkgs.obsidian ];
        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/obsidian \
            --prefix PATH : ${makeBinPath cfg.obsidian.runtimeInputs}
        '';
      };

      runtimeInputs = mkOption {
        type = listOf package;
        default = [ ];
        description = ''
          Additional runtime inputs for the obsidian package.
        '';
      };
    };

    zk = mkProgram pkgs "zk" {
      enable.default = cfg.notes.enable;
    };
  };

  config = mkMerge [
    {
      programs.zk = {
        inherit (cfg.zk) enable package;
      };
    }

    (mkIf cfg.obsidian.enable {
      garden.packages = {
        obsidian = cfg.obsidian.package;
      };
    })
  ];
}
