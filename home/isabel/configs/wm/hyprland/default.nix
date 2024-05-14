{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (osConfig.modules) environment;
in
{
  imports = [ ./config.nix ];

  config = lib.mkIf (environment.desktop == "Hyprland") {
    home.packages = with pkgs; [
      grim
      hyprpicker
    ];

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
