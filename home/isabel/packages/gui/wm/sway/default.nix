{ lib, config, ... }:
let
  inherit (config.garden) environment;
in
{
  imports = [ ./config.nix ];

  config = lib.modules.mkIf (environment.desktop == "Sway") {
    wayland.windowManager.sway = {
      enable = true;
      package = null;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
    };
  };
}
