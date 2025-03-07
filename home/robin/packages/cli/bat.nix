{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;

  inherit (config.garden.programs) defaults;
in
{
  programs.bat = mkIf (isModernShell config) {
    enable = true;

    config = {
      inherit (defaults) pager;
      color = "always";
      style = "changes";
    };
  };
}
