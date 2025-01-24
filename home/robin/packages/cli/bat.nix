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

  syntax = import ../../themes/textmate.nix { inherit (inputs.evergarden) palette; };
in
{
  programs.bat = mkIf (isModernShell config) {
    enable = true;
    themes."evergarden".src = syntax;
    config.theme = "evergarden";

    config = {
      inherit (defaults) pager;
      color = "always";
      style = "changes";
    };
  };
}
