{
  config,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
in {
  config = mkIf (device.hasTPM) {
    security.tpm2 = {
      # enable Trusted Platform Module 2 support
      enable = mkDefault true;
      # enable Trusted Platform 2 userspace resource manager daemon
      abrmd.enable = mkDefault false;
      # set TCTI environment variables to the specified values if enabled
      # - TPM2TOOLS_TCTI
      # - TPM2_PKCS11_TCTI
      tctiEnvironment.enable = mkDefault true;
      # enable TPM2 PKCS#11 tool and shared library in system path
      pkcs11.enable = mkDefault true;
    };
  };
}
