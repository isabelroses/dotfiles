{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (self.lib.validators) isModernShell;
in
{
  programs.fzf = mkIf (isModernShell config) {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableFishIntegration = config.programs.fish.enable;

    defaultCommand = "${getExe pkgs.fd} --type=f --hidden --exclude=.git";
    defaultOptions = [
      "--height=30%"
      "--layout=reverse"
      "--info=inline"
    ];
  };
}
