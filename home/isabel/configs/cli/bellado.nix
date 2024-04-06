{
  lib,
  inputs,
  osConfig,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  imports = [inputs.bellado.homeManagerModules.default];

  config = mkIf (isModernShell osConfig) {
    programs.bellado = {
      enable = true;
      enableAliases = true;
    };
  };
}
