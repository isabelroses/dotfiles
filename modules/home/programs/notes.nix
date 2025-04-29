{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption;
  inherit (self.lib.programs) mkProgram;
  inherit (lib.strings) makeBinPath;
  inherit (lib.types) listOf package;

  cfg = config.garden.programs;
in
{
  options.garden.programs = {
    obsidian = mkProgram pkgs "obsidian" {
      enable.default = config.garden.programs.notes.enable;

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
      enable.default = config.garden.programs.notes.enable;

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
