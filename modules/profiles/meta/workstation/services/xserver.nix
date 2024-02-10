{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) device system environment;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (system.video.enable && builtins.elem device.type acceptedTypes) {
    services.xserver = {
      enable = environment.loginManager != "greetd";

      displayManager = {
        gdm.enable = environment.loginManager == "gdm";
        lightdm.enable = environment.loginManager == "lightdm";
        sddm = {
          enable = environment.loginManager == "sddm";
          wayland.enable = true;
          theme = "${import ../../../../../parts/pkgs/sddm.nix {inherit pkgs lib;}}";
          settings = {
            General = {InputMethod = "";};
          };
        };
      };

      excludePackages = [
        pkgs.xterm
      ];
    };
  };
}
