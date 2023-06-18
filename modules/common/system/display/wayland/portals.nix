{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.system.video;
  env = config.modules.usrEnv;
  inherit (lib) mkForce mkIf;
in {
  config = mkIf (cfg.enable && env.isWayland) {
    xdg.portal = {
      enable = true;

      extraPortals = with pkgs;
      with inputs; [
        xdg-desktop-portal-gtk
        xdg-portal-hyprland.packages.${pkgs.system}.default
      ];
      # xdg-desktop-wlr (this section) is no longer needed, xdg-desktop-portal-hyprland
      # will (and should) override this one, set to false or remove this section
      wlr = {
        enable = mkForce false;
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
