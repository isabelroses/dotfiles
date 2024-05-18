{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf osConfig.modules.programs.gui.terminals.ghostty.enable {
    xdg.configFile."ghostty/config".text = ''
      title = Ghostty

      shell-integration = none

      background-opacity = 0.95

      font-family = Commit Mono
      font-size = 13

      command = /etc/profiles/per-user/isabel/bin/fish --login

      theme = catppuccin-mocha
    '';
  };
}
