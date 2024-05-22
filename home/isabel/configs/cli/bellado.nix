{ lib, osConfig, ... }:
let
  inherit (lib) mkIf isModernShell;
in
{
  config = mkIf (isModernShell osConfig) {
    programs.bellado = {
      enable = true;
      enableAliases = true;
    };
  };
}
