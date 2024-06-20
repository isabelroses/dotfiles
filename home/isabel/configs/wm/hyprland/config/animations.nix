{ osConfig, ... }:
let
  dev = osConfig.modules.device;
in
{
  wayland.windowManager.hyprland.settings.animations = {
    enabled = dev.type != "laptop" && dev.type != "hybrid";
    first_launch_animation = false;

    bezier = [ "overshot,0.13,0.99,0.29,1.1" ];

    animation = [
      "windows,1,4,overshot,slide"
      "border,1,10,default"
      "fade,1,10,default"
      "workspaces,1,6,overshot,slide"
    ];
  };
}
