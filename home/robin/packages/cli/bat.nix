{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;

  inherit (config.garden.programs) defaults;

  inherit (inputs.evergarden) palette;
in
{
  programs.bat = mkIf (isModernShell config) {
    enable = true;
    config.theme = "evergarden";

    themes.evergarden = lib.templates.textmate palette;

    config = {
      inherit (defaults) pager;
      color = "always";
      style = "changes";
    };
  };
}
