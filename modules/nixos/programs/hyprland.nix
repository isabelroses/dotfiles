{ lib, ... }:
let
  inherit (lib.modules) mkIf;
in
{
  config = mkIf true {
    programs.hyprland.enable = true;
    xdg.portal.wlr.enable = false;
  };
}
