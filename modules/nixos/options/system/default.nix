{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [ ./boot.nix ];

  options.modules.system = {
    sound.enable = mkEnableOption "Does the device have sound and its related programs be enabled";
    video.enable = mkEnableOption "Does the device allow for graphical programs";
    bluetooth.enable = mkEnableOption "Should the device load bluetooth drivers and enable blueman";
  };
}
