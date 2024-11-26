{ lib, osConfig, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  config = mkIf (isModernShell osConfig) {
    programs.bellado = {
      enable = true;
      enableAliases = true;
    };
  };
}
