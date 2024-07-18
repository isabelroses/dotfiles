{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
in
{
  config = mkIf osConfig.garden.programs.gui.enable {
    home.packages =
      with pkgs;
      [
        # bitwarden-desktop # password manager
        obsidian # note taking with markdown
        # jellyfin-media-player
        # mangal # tui manga finder + reader
        # insomnia # rest client
        gimp # image editor
      ]
      ++ optionals osConfig.garden.system.sound.enable [ pkgs.pwvucontrol ];
  };
}
