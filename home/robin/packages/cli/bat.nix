{
  inputs,
  lib,
  defaults,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;

  syntax = import ../../themes/textmate.nix { inherit (inputs.evergarden) palette; };
in
{
  programs.bat = mkIf (isModernShell osConfig) {
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
