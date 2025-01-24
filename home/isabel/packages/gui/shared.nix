{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals concatLists;

  hasSound = (osConfig.garden.system ? sound) && osConfig.garden.system.sound.enable;
in
{
  config = mkIf config.garden.programs.gui.enable {
    home.packages = concatLists [
      (builtins.attrValues {
        # inherit (pkgs)
        #   bitwarden-desktop # password manager
        #   jellyfin-media-player
        #   mangal # tui manga finder + reader
        #   insomnia # rest client
        #   inkscape # vector graphics editor
        #   gimp # image editor
        #   ;
      })

      # if the sound option exists then continue the to check if sound.enable is true
      (optionals hasSound [
        pkgs.pwvucontrol
      ])
    ];
  };
}
