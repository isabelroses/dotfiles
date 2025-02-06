{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;
in
{
  programs.bat = mkIf (isModernShell config) {
    # We activate it like this so that catppuccin is applied
    enable = true;
  };
}
