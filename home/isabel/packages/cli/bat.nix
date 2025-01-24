{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  programs.bat = mkIf (isModernShell config) {
    # We activate it like this so that catppuccin is applied
    enable = true;
  };
}
