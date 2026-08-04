{ lib, config, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  hardware.graphics.enable = mkDefault (
    config.garden.profiles.graphical.enable || config.garden.device.gpu != null
  );
}
