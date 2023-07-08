{
  pkgs,
  lib,
  osConfig,
  ...
}:
with lib; let
  programs = osConfig.modules.programs;

  device = osConfig.modules.device;
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
  sys = osConfig.modules.system;
in {
  config = mkIf ((programs.gui.enable && sys.video.enable) && (builtins.elem device.type acceptedTypes)) {
    home.packages = with pkgs; [
      bitwarden
      obsidian
      #zoom-us # I hate this
      xfce.thunar
      pamixer # move
      jellyfin-media-player
      mangal # tui manga finder + reader
    ];
  };
}
