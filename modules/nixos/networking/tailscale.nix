{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool listOf str;
  inherit (lib.lists) optionals;
  inherit (config.services) tailscale;

  sys = config.garden.system.networking;
  cfg = sys.tailscale;
in
{
  options.garden.system.networking.tailscale = {
    enable = mkEnableOption "Tailscale VPN";

    defaultFlags = mkOption {
      type = listOf str;
      default = [ "--ssh" ];
      description = ''
        A list of command-line flags that will be passed to the Tailscale daemon on startup
        using the {option}`config.services.tailscale.extraUpFlags`.
        If `isServer` is set to true, the server-specific values will be appended to the list
        defined in this option.
      '';
    };

    isClient = mkOption {
      type = bool;
      default = cfg.enable;
      example = true;
      description = ''
        Whether the target host should utilize Tailscale client features";
        This option is mutually exclusive with {option}`tailscale.isServer` as they both
        configure Taiscale, but with different flags
      '';
    };

    isServer = mkOption {
      type = bool;
      default = !cfg.isClient;
      example = true;
      description = ''
        Whether the target host should utilize Tailscale server features.
        This option is mutually exclusive with {option}`tailscale.isClient` as they both
        configure Taiscale, but with different flags
      '';
    };
  };

  config = mkIf cfg.enable {
    # make the tailscale command usable to users
    garden.packages = { inherit (pkgs) tailscale; };

    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "${tailscale.interfaceName}" ];
      checkReversePath = "loose";

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ tailscale.port ];
    };

    # enable tailscale, inter-machine VPN service
    services.tailscale = {
      enable = true;
      permitCertUid = "root";
      useRoutingFeatures = mkDefault "server";
      extraUpFlags =
        sys.tailscale.defaultFlags
        ++ optionals sys.tailscale.enable [ "--advertise-exit-node" ];
    };

    # server can't be client and client be server
    assertions = [
      (mkIf (cfg.isClient == cfg.isServer) {
        assertion = false;
        message = ''
          You have enabled both client and server features of the Tailscale service. Unless you are providing your own UpFlags, this is probably not what you want.
        '';
      })
    ];
  };
}
