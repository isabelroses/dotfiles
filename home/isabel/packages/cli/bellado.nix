{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  config = mkIf (isModernShell config) {
    programs.bellado = {
      enable = true;
      enableAliases = true;
    };
  };
}
