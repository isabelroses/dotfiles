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
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.gui.enable && video.enable && defaults.fileManager == "dolphin") {
    home.packages = with pkgs; [
      libsForQt5.dolphin
    ];
  };
}
