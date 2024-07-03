{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}:
let
  inherit (osConfig.garden) environment;
in
{
  imports = [ ./config ];

  config = lib.mkIf (environment.desktop == "Hyprland") {
    home.packages = with pkgs; [
      grim
      swww
      hyprpicker
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs'.hyprland.packages.default;
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
