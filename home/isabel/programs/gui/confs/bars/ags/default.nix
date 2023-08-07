{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
  programs = osConfig.modules.programs;
  sys = osConfig.modules.system;
in {
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && sys.video.enable && programs.default.bar == "ags") {
    home = {
      file.".config/ags".source = ./config;
      packages = with pkgs; [
        nur.repos.bella.ags
        socat
      ];
    };
  };
}
