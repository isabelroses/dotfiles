{
  osConfig,
  lib,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  config = mkIf (isModernShell osConfig) {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
