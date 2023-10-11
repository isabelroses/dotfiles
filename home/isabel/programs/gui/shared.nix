{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.gui.enable) {
    home.packages = with pkgs; [
      bitwarden
      obsidian
      #zoom-us # I hate this
      xfce.thunar
      pamixer # move
      jellyfin-media-player
      mangal # tui manga finder + reader
      insomnia # rest client
    ];
  };
}
