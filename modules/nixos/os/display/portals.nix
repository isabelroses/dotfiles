{
  lib,
  pkgs,
  config,
  ...
}: let
  sys = config.modules.system;
  env = config.modules.environment;
  inherit (lib) mkForce mkIf isWayland;
in {
  config = mkIf (sys.video.enable && pkgs.stdenv.isLinux) {
    xdg.portal = {
      enable = true;
      # xdgOpenUsePortal = true;
      config.common = {
        default = "gtk";

        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];

      wlr = {
        enable = mkForce (isWayland config && env.desktop != "Hyprland");
        settings = {
          screencast = {
            max_fps = 60;
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          };
        };
      };
    };
  };
}
