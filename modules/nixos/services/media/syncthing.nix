{ lib, config, ... }:
let

  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  cfg = config.garden.services.media.syncthing;
in
{
  options.garden.services.media.syncthing = mkServiceOption "syncthing" { };

  # I don't really want to expose the GUI for this one, try ssh instead
  # > ssh <hostname> -L 18384:localhost:8384
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;

      dataDir = "/srv/storage/syncthing";
    };
  };
}
