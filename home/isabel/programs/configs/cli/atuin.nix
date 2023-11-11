{
  osConfig,
  lib,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  config = mkIf (isModernShell osConfig) {
    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        dialect = "uk";
        show_preview = true;
        style = "compact";
        update_check = false;
      };
    };
  };
}
