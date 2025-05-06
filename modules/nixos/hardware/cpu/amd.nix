{ lib, config, ... }:
let
  inherit (lib) mkIf;
  inherit (config.garden) device;
in
{
  config = mkIf (device.cpu == "amd" || device.cpu == "vm-amd") {
    hardware.cpu.amd.updateMicrocode = true;

    boot.kernelModules = [
      "kvm-amd"
      "amd-pstate"
    ];
  };
}
