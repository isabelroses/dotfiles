{
  pkgs,
  self,
  osClass,
  ...
}:
let
  inherit (self.lib) mkProgram;
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
}
