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

      disabledPlugins = [
        "sap"
        "handsfree"
      ];

      # https://github.com/bluez/bluez/blob/master/src/main.conf
      settings = {
        General = {
          JustWorksRepairing = "always";
          MultiProfile = "multiple";

          # https://wiki.nixos.org/wiki/Bluetooth#Enabling_A2DP_Sink
          Enable = "Source,Sink,Media,Socket";

          # wake the controller up quickly so the headset reconnects with
          # minimal delay instead of waiting on the slow page scan window
          FastConnectable = true;

          # experimental features expose HFP codec negotiation and battery
          # level reporting (BAS) for the headset
          Experimental = true;
          KernelExperimental = true;
        };

        Policy = {
          # reconnect known devices (the headset) automatically on boot/resume
          AutoEnable = true;

          # retry the headset link a few times with backoff after a drop
          ReconnectAttempts = 7;
          ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
        };
      };
    };

    boot.kernelModules = [ "btusb" ];

    services.blueman.enable = true;
  };
}
