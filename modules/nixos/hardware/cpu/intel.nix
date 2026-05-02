{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (config.garden) device;
in
{
  config = mkIf (device.cpu == "intel" || device.cpu == "vm-intel") {
    hardware.cpu.intel.updateMicrocode = true;

    boot = {
      kernelModules = [ "kvm-intel" ];
      kernelParams = [
        "i915.fastboot=1"
        "enable_gvt=1"
      ];
    };
  };
}
