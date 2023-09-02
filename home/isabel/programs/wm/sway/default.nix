{
  lib,
  osConfig,
  ...
}: let
  inherit (osConfig.modules) usrEnv;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  imports = [./config.nix];
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isWayland osConfig && usrEnv.desktop == "Sway") {
    wayland.windowManager.sway = {
      enable = true;
      package = null;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
    };
  };
}
