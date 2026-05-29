{ lib, config, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
  inherit (lib.modules) mkIf;

  inherit (config.garden) device;
in
{
  options.garden.device.capabilities.tpm = mkOption {
    type = bool;
    default = false;
    description = "Whether the system has tpm support";
  };

  config = mkIf device.capabilities.tpm {
    security.tpm2 = {
      enable = true;

      # set TCTI environment variables to the specified values if enabled
      # - TPM2TOOLS_TCTI
      # - TPM2_PKCS11_TCTI
      tctiEnvironment.enable = true;

      # enable TPM2 PKCS#11 tool and shared library in system path
      pkcs11.enable = true;
    };

    boot.initrd.kernelModules = [ "tpm" ];
  };
}
