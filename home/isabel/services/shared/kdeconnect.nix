{
  lib,
  osConfig,
  ...
}: let
  inherit (osConfig.modules.system) video;
  inherit (lib) mkIf isAcceptedDevice;

  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  config = mkIf ((isAcceptedDevice osConfig acceptedTypes) && video.enable) {
    # connect my phone, please its so inconsistant
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
