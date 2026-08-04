{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (config.garden) device;
in
{
  config = mkIf (device.cpu == "amd") {
    hardware.cpu.amd.updateMicrocode = true;

    boot.kernelModules = [
      "kvm-amd"
      "amd-pstate"
    ];
  };
}
