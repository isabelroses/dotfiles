{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) anyHome;

  cond = anyHome config (conf: conf.wayland.windowManager.hyprland.enable);
in
{
  config = mkIf cond {
    programs.hyprland.enable = true;
    xdg.portal.wlr.enable = false;
  };
}
