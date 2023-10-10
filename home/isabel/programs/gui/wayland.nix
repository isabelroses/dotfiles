{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && (lib.isWayland osConfig) && osConfig.modules.programs.gui.enable) {
    home.packages = with pkgs; [
      swappy
      #swaynotificationcenter
      wlsunset
      wl-gammactl
      pavucontrol
    ];
  };
}
