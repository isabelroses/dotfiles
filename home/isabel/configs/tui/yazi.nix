{
  lib,
  config,
  osConfig,
  ...
}:
{
  programs.yazi = lib.mkIf osConfig.modules.programs.tui.enable {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
