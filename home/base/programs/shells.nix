{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.programs) mkProgram;
in
{
  options.garden.programs = {
    bash = mkProgram pkgs "bash" {
      enable.default = true;
      package.default = pkgs.bashInteractive;
    };

    zsh = mkProgram pkgs "zsh" {
      enable.default = pkgs.stdenv.hostPlatform.isDarwin;
    };

    fish = mkProgram pkgs "fish" { };

    nushell = mkProgram pkgs "nushell" { };
  };
}
