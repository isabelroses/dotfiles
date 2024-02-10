{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.modules.device = {
    hasBluetooth = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not the system has bluetooth support";
    };

    hasSound = mkOption {
      type = types.bool;
      default = true;
      description = "Whether the system has sound support (usually true except for servers)";
    };

    hasTPM = mkOption {
      type = types.bool;
      default = false;
      description = "Whether the system has tpm support";
    };
  };
}
