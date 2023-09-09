{
  osConfig,
  lib,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isModernShell osConfig) {
    programs.eza = {
      enable = true;
      enableAliases = true;
      extraOptions = [
        "--group-directories-first"
      ];
      icons = true;
    };
  };
}
