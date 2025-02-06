{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
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
      settings = mkOption {
        inherit (pkgs.formats.toml { }) type;
        default = { };
      };
    };
  };

  config = mkIf (cfg.zk.enable && cfg.zk.settings != { }) {
    xdg.configFile."zk/config.toml".source = pkgs.writers.writeTOML "zk-conf.toml" cfg.zk.settings;
  };
}
