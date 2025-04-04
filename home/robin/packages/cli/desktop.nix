{
  lib,
  self,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;

  cfg = config.garden.programs;
in
{
  config = mkIf (hasProfile osConfig [ "graphical" ] && cfg.cli.enable && cfg.gui.enable) {
    garden.packages = {
      inherit (pkgs)
        libnotify # needed for some notifications
        # bitwarden-cli # bitwarden, my chosen password manager
        brightnessctl # brightness managed via cli
        # vhs # programmatically make gifs
        ;
    };
  };
}
