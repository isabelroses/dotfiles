{
  lib,
  pkgs,
  self,
  config,
  osClass,
  ...
}:
let
  inherit (self.lib) mkProgram;

  progs = config.garden.programs;
in
{
  options.garden.programs = {
    bash = mkProgram pkgs "bash" {
      enable.default = true;
      package.default = pkgs.bashInteractive;
    };

    zsh = mkProgram pkgs "zsh" {
      enable.default = osClass == "darwin";
    };

    fish = mkProgram pkgs "fish" { };

    nushell = mkProgram pkgs "nushell" { };
  };

  config = {
    xdg.configFile.shell = {
      source = lib.getExe progs.${progs.defaults.shell}.package;
    };
  };
}
