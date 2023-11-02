{
  osConfig,
  lib,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isModernShell osConfig) {
    programs.tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };
        updates.auto_update = true;
      };
    };
  };
}
