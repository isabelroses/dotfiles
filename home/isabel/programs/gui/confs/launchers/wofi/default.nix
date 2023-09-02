{
  config,
  lib,
  osConfig,
  defaults,
  ...
}: let
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  imports = [./config.nix];
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && (lib.isWayland osConfig) && osConfig.modules.usrEnv.programs.gui.enable && defaults.launcher == "wofi") {
    programs.wofi.enable = true;
  };
}
