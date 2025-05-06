{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;

  sys = config.garden.system;
in
{
  options.garden = {
    device.hasBluetooth = mkOption {
      type = bool;
      default = true;
      description = "Whether or not the system has bluetooth support";
    };

    system.bluetooth.enable = mkEnableOption "Should the device load bluetooth drivers and enable blueman";
  };

  config = mkIf sys.bluetooth.enable {
    garden.system.boot.extraKernelParams = [ "btusb" ];

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
