{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.garden.programs.hyprland;
in
{
  imports = [ ./config ];

  config = lib.mkIf cfg.enable {
    garden.packages = { inherit (pkgs) swww hyprpicker; };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      inherit (cfg) package;

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
