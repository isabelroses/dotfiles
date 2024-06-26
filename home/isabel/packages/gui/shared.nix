{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.modules.programs.gui.enable {
    home.packages = with pkgs; [
      bitwarden-desktop # password manager
      obsidian # note taking with markdown
      pamixer # move evntually
      # jellyfin-media-player
      # mangal # tui manga finder + reader
      # insomnia # rest client
      nextcloud-client # cloud storage
    ];
  };
}
