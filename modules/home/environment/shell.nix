# this file is used to enable or disable shell intergrations based on the shell itself
{ config, ... }:
{
  home.shell = {
    # disable the gloabl enable
    enableShellIntegration = false;

    enableBashIntegration = config.programs.bash.enable;
    enableIonIntegration = config.programs.ion.enable;
    enableNushellIntegration = config.programs.nushell.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableFishIntegration = config.programs.fish.enable;
  };
}
