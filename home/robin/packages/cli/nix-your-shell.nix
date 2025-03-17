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
  programs.nix-your-shell = mkIf (isModernShell config) {
    enable = true;
  };
}
