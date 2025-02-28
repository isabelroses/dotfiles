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
  programs.zoxide = mkIf (isModernShell config) {
    enable = true;

    options = [ "--cmd cd" ];
  };
}
