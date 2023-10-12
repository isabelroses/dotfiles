{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) device programs system;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (system.video.enable && builtins.elem device.type acceptedTypes) {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = programs.defaults.loginManager == "gdm";
      displayManager.lightdm.enable = programs.defaults.loginManager == "lightdm";
      displayManager.sddm = {
        enable = programs.defaults.loginManager == "sddm";
        wayland.enable = true;
        theme = "${import ../../../../../parts/pkgs/sddm.nix {inherit pkgs lib;}}";
        settings = {
          General = {InputMethod = "";};
        };
      };
    };
  };
}
