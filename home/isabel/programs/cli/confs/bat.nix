{
  osConfig,
  lib,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isModernShell osConfig) {
    programs.bat = {
      enable = true;
      catppuccin.enable = true;
    };
  };
}
