{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkOption
    mkEnableOption
    optionals
    ;
  inherit (lib.types) bool listOf str;

  inherit (config.services) tailscale;

  cfg = config.garden.system.networking.tailscale;
in
{
  options.garden.system.networking.tailscale = {
    enable = mkEnableOption "Tailscale VPN" // {
      default = true;
      defaultText = "true";
    };

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
      default = config.garden.profiles.workstation.enable;
      defaultText = lib.literalExpression "config.garden.profiles.workstation.enable";
      example = true;
      description = ''
        Whether the target host should utilize Tailscale client features";
        This option is mutually exclusive with {option}`config.services.tailscale.isServer` as they both
        configure Taiscale, but with different flags
      '';
    };

    isServer = mkOption {
      type = bool;
      default = config.garden.profiles.server.enable;
      defaultText = lib.literalExpression "config.garden.profiles.server.enable";
      example = true;
      description = ''
        Whether the target host should utilize Tailscale server features.
        This option is mutually exclusive with {option}`config.services.tailscale.isClient` as they both
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
      extraUpFlags = cfg.defaultFlags ++ optionals cfg.enable [ "--advertise-exit-node" ];
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
