{
  config,
  lib,
  osConfig,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
  sys = osConfig.modules.system;
  programs = osConfig.modules.programs;
in {
  imports = [./config.nix];
  config = mkIf (builtins.elem device.type acceptedTypes && sys.video.enable && programs.gui.enable && programs.default.launcher == "wofi") {
    programs.wofi.enable = true;
  };
}
