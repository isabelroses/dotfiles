{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  imports = [./nftables.nix];

  options.modules.system.networking = {
    optimizeTcp = mkEnableOption "Enable tcp optimizations";
    nftables.enable = mkEnableOption "nftables firewall";

    wirelessBackend = mkOption {
      type = types.enum ["iwd" "wpa_supplicant"];
      default = "iwd";
      description = ''
        Backend that will be used for wireless connections using either `networking.wireless`
        or `networking.networkmanager.wifi.backend`
        Defaults to wpa_supplicant until iwd is stable.
      '';
    };
  };
}
