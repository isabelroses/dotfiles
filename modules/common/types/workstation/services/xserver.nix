{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) device usrEnv system;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (system.video.enable && builtins.elem device.type acceptedTypes) {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = usrEnv.programs.defaults.loginManager == "gdm";
      displayManager.lightdm.enable = usrEnv.programs.defaults.loginManager == "lightdm";
      displayManager.sddm = {
        enable = usrEnv.programs.defaults.loginManager == "sddm";
        theme = "${import ../../../../../parts/pkgs/sddm.nix {inherit pkgs lib;}}";
        settings = {
          General = {InputMethod = "";};
        };
      };
    };
  };
}
