{
  lib,
  config,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.modules.programs.tui.enable {
    programs.zellij = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;

      settings = {
        default_shell = "fish";
        layout = "compact";
        ui.pane_frames.hide_session_name = true;
      };
    };

    xdg.configFile."zellij/layouts/default.kdl".text = ''
      layout {
          pane borderless=true
          pane size=1 borderless=true {
              plugin location="zellij:tab-bar"
          }
      }
    '';
  };
}
