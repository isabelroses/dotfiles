{
  lib,
  config,
  ...
}:
{
  programs.yazi = lib.modules.mkIf config.garden.programs.tui.enable {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
