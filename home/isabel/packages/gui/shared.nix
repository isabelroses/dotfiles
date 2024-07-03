{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.garden.programs.gui.enable {
    home.packages = with pkgs; [
      bitwarden-desktop # password manager
      obsidian # note taking with markdown
      # jellyfin-media-player
      # mangal # tui manga finder + reader
      # insomnia # rest client
      nextcloud-client # cloud storage
      gimp # image editor
    ];
  };
}
