{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;

  sys = config.modules.system;
in
{
  options.modules = {
    device.hasBluetooth = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not the system has bluetooth support";
    };

    system.bluetooth.enable = mkEnableOption "Should the device load bluetooth drivers and enable blueman";
  };

  config = lib.mkIf sys.bluetooth.enable {
    modules.system.boot.extraKernelParams = [ "btusb" ];
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
      #hsphfpd.enable = true;
      powerOnBoot = true;
      disabledPlugins = [ "sap" ];
      settings = {
        General = {
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
        };
      };
    };

    # https://wiki.nixos.org/wiki/Bluetooth
    services.blueman.enable = true;
  };
}
