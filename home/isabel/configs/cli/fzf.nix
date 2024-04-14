{
  lib,
  config,
  osConfig,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "wsl" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isModernShell osConfig) {
    programs.fzf = {
      enable = true;
      catppuccin.enable = true;

      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;

      defaultOptions = ["--height=30%" "--layout=reverse" "--info=inline"];
    };
  };
}
