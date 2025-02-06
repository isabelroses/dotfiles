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
  config = mkIf (isModernShell config) {
    programs.bellado = {
      enable = true;
      enableAliases = true;
    };
  };
}
