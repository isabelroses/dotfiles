{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
{
  programs.fzf = lib.mkIf (lib.isModernShell osConfig) {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableFishIntegration = config.programs.fish.enable;

    defaultCommand = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
    defaultOptions = [
      "--height=30%"
      "--layout=reverse"
      "--info=inline"
    ];
  };
}
