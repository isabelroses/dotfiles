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
      builtins.attrValues {
        inherit (pkgs)
          # bitwarden-desktop # password manager
          # jellyfin-media-player
          # mangal # tui manga finder + reader
          # insomnia # rest client
          gimp # image editor
          ;
      }
      # if the sound option exists then continue the to check if sound.enable is true
      ++ optionals ((osConfig.garden.system ? sound) && osConfig.garden.system.sound.enable) [
        pkgs.pwvucontrol
      ];
  };
}
