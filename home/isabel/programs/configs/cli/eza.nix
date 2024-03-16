{
  lib,
  config,
  osConfig,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  config = mkIf (isModernShell osConfig) {
    programs.eza = {
      enable = true;
      icons = true;

      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;

      extraOptions = [
        "--group"
        "--group-directories-first"
        "--header"
        "--no-permissions"
        "--octal-permissions"
      ];
    };
  };
}
