{
  config,
  pkgs,
  lib,
  ...
}: 
let
  programs = osConfig.modules.programs;
  device = osConfig.modules.device;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((builtins.elem device.type acceptedTypes) && (programs.cli.enable)) {
    programs.lazygit = {
      enable = true;
      catppuccin.enable = true;
    };
  };
}
