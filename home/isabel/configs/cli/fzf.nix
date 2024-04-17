{
  lib,
  config,
  osConfig,
  ...
}: {
  programs.fzf = lib.mkIf (lib.isModernShell osConfig) {
    enable = true;
    catppuccin.enable = true;

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableFishIntegration = config.programs.fish.enable;

    defaultOptions = ["--height=30%" "--layout=reverse" "--info=inline"];
  };
}
