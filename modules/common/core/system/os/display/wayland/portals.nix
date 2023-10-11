{
  config,
  lib,
  pkgs,
  ...
}: let
  sys = config.modules.system;
  env = config.modules.usrEnv;
  inherit (lib) mkForce mkIf;
in {
  config = mkIf (sys.video.enable) {
    xdg.portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      # xdg-desktop-wlr (this section) is no longer needed, xdg-desktop-portal-hyprland
      # will (and should) override this one, set to false or remove this section
      wlr = {
        enable = mkForce (env.isWayland && env.desktop != "Hyprland");
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
