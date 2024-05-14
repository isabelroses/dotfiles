{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (config.modules) device;
in
{
  config = lib.mkIf (device.cpu == "intel" || device.cpu == "vm-intel") {
    hardware.cpu.intel.updateMicrocode = true;

    boot = {
      kernelModules = [ "kvm-intel" ];
      kernelParams = [
        "i915.fastboot=1"
        "enable_gvt=1"
      ];
    };

    environment.systemPackages = with pkgs; [ intel-gpu-tools ];
  };
}
