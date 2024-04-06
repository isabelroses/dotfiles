{
  lib,
  osConfig,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "wsl" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isModernShell osConfig) {
    programs.bat = {
      enable = true;
      catppuccin.enable = true;
    };
  };
}
