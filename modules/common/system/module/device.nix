{lib, ...}:
with lib; {
  options.modules.device = {
    type = mkOption {
      type = types.enum ["laptop" "desktop" "server" "hybrid" "lite"];
    };

    # the type of cpu your system has - vm and regular cpus currently do not differ
    # as I do not work with vms, but they have been added for forward-compatibility
    cpu = mkOption {
      type = types.enum ["pi" "intel" "vm-intel" "amd" "vm-amd" null];
      default = null;
    };


    gpu = mkOption {
      type = types.enum ["amd" "intel" "nvidia" null];
      default = null;
      description = "the manifacturer/type of the primary system gpu";
    };

    monitors = mkOption {
      type = types.listOf types.string;
      default = [];
      description = ''
        this does not affect any drivers and such, it is only necessary for
        declaring things like monitors in window manager configurations
        you can avoid declaring this, but I'd rather if you did declare
      '';
    };

    # bluetooth is an insecure protocol if left unchedked, so while this defaults to true
    # but the bluetooth.enable option does and should not.
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
  };
}
