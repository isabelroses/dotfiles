{ lib, osConfig, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  config = mkIf (isModernShell osConfig) {
    programs.bellado = {
      enable = true;
      # enable shell aliases:
      # bel   -> bellado
      # bell  -> bellado -l  # list todo's
      # bella -> bellado -la # list all todo's
      # bellc -> bellado -lc # list completed todo's
      enableAliases = true;
    };
  };
}
