{config, lib, osConfig, ...}: let
  inherit (lib) mkIf;
  inherit (osConfig.modules) programs;
in {
  config.programs.lazygit = mkIf (programs.tui.enable) {
    enable = true;
    catppuccin.enable = true;
  };
}
