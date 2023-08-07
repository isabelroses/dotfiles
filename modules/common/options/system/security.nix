{
  lib,
  pkgs,
  ...
}:
with lib; {
  # should we optimize tcp networking
  options.modules.system.security = {
    fixWebcam = mkEnableOption "Fix the purposefully broken webcam by un-blacklisting the related kernel module.";
    secureBoot = mkEnableOption "Enable secure-boot and load necessary packages.";
  };
}
