{
  lib,
  config,
  osConfig,
  ...
}:
{
  programs.yazi = lib.modules.mkIf osConfig.garden.programs.tui.enable {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
