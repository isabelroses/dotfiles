{ lib, config, ... }:
let
  inherit (lib) types mkOption;
  inherit (config.garden.system.networking) wirelessBackend;
in
{

  options.garden.system.networking.wirelessBackend = mkOption {
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

  config = {
    # enable wireless database, it helps keeping wifi speedy
    hardware.wirelessRegulatoryDatabase = true;

    networking.wireless = {
      # wpa_supplicant
      enable = wirelessBackend == "wpa_supplicant";
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;

      extraConfig = ''
        update_config=1
      '';

      # iwd
      iwd = {
        enable = wirelessBackend == "iwd";

        settings = {
          Settings.AutoConnect = true;

          General = {
            # more things that my uni hates me for
            # AddressRandomization = "network";
            # AddressRandomizationRange = "full";
            EnableNetworkConfiguration = true;
            RoamRetryInterval = 15;
          };

          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
        };
      };
    };
  };
}
