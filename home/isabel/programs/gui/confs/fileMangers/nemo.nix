{
  osConfig,
  lib,
  pkgs,
  defaults,
  ...
}: let
  inherit (osConfig.modules.system) video;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.usrEnv.programs.gui.enable && video.enable && defaults.fileManager == "nemo") {
    home.packages = with pkgs; [
      cinnamon.nemo-with-extensions
      cinnamon.nemo-fileroller
      cinnamon.nemo-emblems
    ];
  };
}
