{
  osConfig,
  lib,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.usrEnv.programs.cli.enable) {
    programs.bat = {
      enable = true;
      catppuccin.enable = true;
    };
  };
}
