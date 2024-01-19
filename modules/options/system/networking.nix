{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  sys = config.modules.system;
  cfg = sys.networking.tailscale;
in {
  options.modules.system.networking = {
    optimizeTcp = mkEnableOption "Enable tcp optimizations";

    wirelessBackend = mkOption {
      type = types.enum ["iwd" "wpa_supplicant"];
      default = "wpa_supplicant";
      description = ''
        Backend that will be used for wireless connections using either `networking.wireless`
        or `networking.networkmanager.wifi.backend`
        Defaults to wpa_supplicant until iwd is stable.
      '';
    };

    tailscale = {
      enable = mkEnableOption "Tailscale VPN";
      defaultFlags = mkOption {
        type = with types; list (list string);
        default = ["--ssh"];
        description = ''
          A list of command-line flags that will be passed to the Tailscale daemon on startup
          using the {option}`config.services.tailscale.extraUpFlags`.
          If `isServer` is set to true, the server-specific values will be appended to the list
          defined in this option.
        '';
      };

      isClient = mkOption {
        type = types.bool;
        default = cfg.enable;
        example = true;
        description = ''
          Whether the target host should utilize Tailscale client features";
          This option is mutually exlusive with {option}`tailscale.isServer` as they both
          configure Taiscale, but with different flags
        '';
      };

      isServer = mkOption {
        type = types.bool;
        default = !cfg.isClient;
        example = true;
        description = ''
          Whether the target host should utilize Tailscale server features.
          This option is mutually exlusive with {option}`tailscale.isClient` as they both
          configure Taiscale, but with different flags
        '';
      };
    };
  };
}
