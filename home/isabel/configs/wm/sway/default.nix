{ lib, osConfig, ... }:
let
  inherit (osConfig.modules) environment;
in
{
  imports = [ ./config.nix ];

  config = lib.mkIf (environment.desktop == "Sway") {
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
