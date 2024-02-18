{
  config,
  lib,
  ...
}: let
  inherit (config.modules) device;
  inherit (lib) mkIf;
in {
  config = mkIf (device.cpu == "amd" || device.cpu == "vm-amd") {
    hardware.cpu.amd.updateMicrocode = true;

    boot.kernelModules = [
      "kvm-amd"
      "amd-pstate"
    ];
  };
}
