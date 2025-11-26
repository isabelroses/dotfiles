{
  lib,
  self,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) anyHome;

  cond = anyHome config (conf: conf.wayland.windowManager.hyprland.enable);
in
{
  config = mkIf cond {
    services.displayManager.sessionPackages = [ pkgs.hyprland ];
    programs.hyprland.enable = true;
    xdg.portal.wlr.enable = false;
  };
}
