{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.garden.system.security = {
    fixWebcam = mkEnableOption "Fix the purposefully broken webcam by un-blacklisting the related kernel module.";
    tor.enable = mkEnableOption "Tor daemon";
    lockModules = mkEnableOption "Lock kernel modules to the ones specified in the configuration. Highly breaking.";
  };
}
