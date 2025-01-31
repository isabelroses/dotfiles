{
  lib,
  pkgs,
  config,
  ...
}:
let
  env = config.garden.environment;
in
{
  imports = [ ./config ];

  config = lib.modules.mkIf (env.desktop == "Hyprland") {
    garden.packages = { inherit (pkgs) swww hyprpicker; };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      systemd = {
        enable = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };
    };
  };
}
