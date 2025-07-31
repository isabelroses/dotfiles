{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.system.bluetooth;
in
{
  options.garden = {
    device.capabilities.bluetooth = mkEnableOption "bluetooth support" // {
      default = true;
    };

    system.bluetooth.enable = mkEnableOption "loading bluetooth drivers and enable blueman";
  };

  # https://wiki.nixos.org/wiki/Bluetooth
  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;

      # this is experimental but it seems to work and is cool
      hsphfpd.enable = true;

      disabledPlugins = [ "sap" ];

      # https://github.com/bluez/bluez/blob/master/src/main.conf
      settings.General = {
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
    };

    boot.kernelModules = [ "btusb" ];

    services.blueman.enable = true;
  };
}
