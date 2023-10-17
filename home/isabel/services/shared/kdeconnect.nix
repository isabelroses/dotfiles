{
  lib,
  osConfig,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
  sys = osConfig.modules.system;
in {
  config = mkIf (builtins.elem device.type acceptedTypes && sys.video.enable) {
    # connect my phone
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
