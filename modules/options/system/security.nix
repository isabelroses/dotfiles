{lib, ...}: let
  inherit (lib) mdDoc mkEnableOption;
in {
  # should we optimize tcp networking
  options.modules.system.security = {
    fixWebcam = mkEnableOption (mdDoc "Fix the purposefully broken webcam by un-blacklisting the related kernel module.");
    secureBoot = mkEnableOption (mdDoc "Enable secure-boot and load necessary packages.");
    lockModules = mkEnableOption (mdDoc "Lock kernel modules to the ones specified in the configuration. Highly breaking.");
  };
}
