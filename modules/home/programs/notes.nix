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
      };
    };

    zk = mkProgram pkgs "zk" {
      enable.default = cfg.notes.enable;

      settings = mkOption {
        inherit (pkgs.formats.toml { }) type;
        default = { };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.zk.enable {
      xdg.configFile = mkIf (cfg.zk.settings != { }) {
        "zk/config.toml".source = pkgs.writers.writeTOML "zk-conf.toml" cfg.zk.settings;
      };

      garden.packages = {
        zk = cfg.zk.package;
      };
    })

    (mkIf cfg.obsidian.enable {
      garden.packages = {
        obsidian = cfg.obsidian.package;
      };
    })
  ];
}
