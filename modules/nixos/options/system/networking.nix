{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;

  sys = config.modules.system;
  cfg = sys.networking.tailscale;
in
{
  options.modules.system.networking = {
    optimizeTcp = mkEnableOption "Enable tcp optimizations";

    wirelessBackend = mkOption {
      type = types.enum [
        "iwd"
        "wpa_supplicant"
      ];
      default = "wpa_supplicant";
      description = ''
        Backend that will be used for wireless connections using either `networking.wireless`
        or `networking.networkmanager.wifi.backend`
        Defaults to wpa_supplicant until iwd is stable.
      '';
    };
  };
}
