{
  lib,
  config,
  ...
}:
{
  config = lib.modules.mkIf config.garden.programs.tui.enable {
    programs.zellij = {
      enable = true;

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
