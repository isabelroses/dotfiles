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
      swappy # used for screenshot area selection
      # swaynotificationcenter
      wlsunset # reduce blue light at night
      wl-gammactl
      pavucontrol # TODO move audio
    ];
  };
}
