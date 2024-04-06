{
  lib,
  config,
  osConfig,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  config = mkIf (isModernShell osConfig) {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableNushellIntegration = config.programs.nushell.enable;
    };
  };
}
