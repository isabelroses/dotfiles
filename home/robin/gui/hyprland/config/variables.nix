{
  config,
  inputs,
  ...
}:
let
  inherit (config.evergarden) variant;
  palette = inputs.evergarden.lib.palette.${variant};
in
{
  wayland.windowManager.hyprland.settings = {
    "$notifycmd" = "notify-send -e -a hyprland -h string:x-canonical-private-synchronous:hypr-cfg -u low";

    "$red" = "0xff${palette.red}";
    "$orange" = "0xff${palette.orange}";
    "$yellow" = "0xff${palette.yellow}";
    "$lime" = "0xff${palette.lime}";
    "$green" = "0xff${palette.green}";
    "$aqua" = "0xff${palette.aqua}";
    "$skye" = "0xff${palette.skye}";
    "$snow" = "0xff${palette.snow}";
    "$blue" = "0xff${palette.blue}";
    "$purple" = "0xff${palette.purple}";
    "$pink" = "0xff${palette.pink}";
    "$cherry" = "0xff${palette.cherry}";
    "$text" = "0xff${palette.text}";
    "$subtext1" = "0xff${palette.subtext1}";
    "$subtext0" = "0xff${palette.subtext0}";
    "$overlay2" = "0xff${palette.overlay2}";
    "$overlay1" = "0xff${palette.overlay1}";
    "$overlay0" = "0xff${palette.overlay0}";
    "$surface2" = "0xff${palette.surface2}";
    "$surface1" = "0xff${palette.surface1}";
    "$surface0" = "0xff${palette.surface0}";
    "$base" = "0xff${palette.base}";
    "$mantle" = "0xff${palette.mantle}";
    "$crust" = "0xff${palette.crust}";
  };
}
