{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;

  inherit (config.garden.programs) defaults;

  inherit (self.lib.evergarden) palette;
in
{
  programs.bat = mkIf (isModernShell config) {
    enable = true;
    config.theme = "evergarden";

    themes.evergarden.src = pkgs.writeTextFile {
      name = "syntax-evergarden";
      text = self.lib.template.textmate palette;
    };

    config = {
      inherit (defaults) pager;
      color = "always";
      style = "changes";
    };
  };
}
