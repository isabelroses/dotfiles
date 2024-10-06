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
    neovim = mkProgram pkgs "neovim" {
      enable.default = true;
    };
    vscode = mkProgram pkgs "vscode" { };
    zed = mkProgram pkgs "zed-editor" { };
    micro = mkProgram pkgs "micro" { };
  };
}
