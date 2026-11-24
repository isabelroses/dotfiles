{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkSecret;
  inherit (lib.lists) optional;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption mkEnableOption;
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

    tailnet = mkOption {
      type = str;
      default = "alewife-galaxy.ts.net";
      description = "The tailnet's MagicDNS domain.";
    };

    acceptDns = mkOption {
      type = bool;
      default = config.services.resolved.enable;
      defaultText = lib.options.literalExpression "config.services.resolved.enable";
      description = "Whether tailscaled manages DNS, which needs resolved.";
    };

    advertiseRoutes = mkOption {
      type = listOf str;
      default = [ ];
      example = [ "192.168.10.0/24" ];
      description = "Subnets this host routes into the tailnet.";
    };

    defaultFlags = mkOption {
      type = listOf str;
      default = [ ];
      description = ''
        A list of command-line flags that will be passed to the Tailscale daemon on startup
        using the {option}`config.services.tailscale.extraSetFlags`.
        If `isServer` is set to true, the server-specific values will be appended to the list
        defined in this option.
      '';
    };

    isClient = mkOption {
      type = bool;
      default = config.garden.profiles.workstation.enable;
      defaultText = lib.options.literalExpression "config.garden.profiles.workstation.enable";
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
      defaultText = lib.options.literalExpression "config.garden.profiles.server.enable";
      example = true;
      description = ''
        Whether the target host should utilize Tailscale server features.
        This option is mutually exclusive with {option}`config.services.tailscale.isClient` as they both
        configure Taiscale, but with different flags
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "${tailscale.interfaceName}" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ tailscale.port ];
    };

    # enable tailscale, inter-machine VPN service
    services.tailscale = {
      enable = true;
      permitCertUid = "root";
      useRoutingFeatures = mkDefault (if cfg.isServer then "server" else "client");
      extraSetFlags =
        cfg.defaultFlags
        ++ optional cfg.isServer "--advertise-exit-node"
        ++ optional (!cfg.acceptDns) "--accept-dns=false"
        ++ optional (cfg.advertiseRoutes != [ ]) "--advertise-routes=${concatStringsSep "," cfg.advertiseRoutes}";

      # new servers join pre-tagged, once their key is in .sops.yaml
      authKeyFile = mkIf cfg.isServer config.sops.secrets.tailscale-auth-key.path;
      authKeyParameters.preauthorized = mkIf cfg.isServer true;
      extraUpFlags = optional cfg.isServer "--advertise-tags=tag:server";
    };

    sops.secrets.tailscale-auth-key = mkIf cfg.isServer (mkSecret {
      file = "tailscale";
      key = "auth-key";
    });

    # so switches reapply changed flags
    systemd.services.tailscaled-set = mkIf (tailscale.extraSetFlags != [ ]) {
      serviceConfig.RemainAfterExit = true;
    };

    # what magicdns would add for us
    networking.search = mkIf (!cfg.acceptDns) [ cfg.tailnet ];

    # use nftables directly rather than letting tailscaled guess
    # <https://wiki.nixos.org/wiki/Tailscale#Native_nftables_Support_(Modern_Setup)>
    systemd.services.tailscaled.environment = mkIf config.networking.nftables.enable {
      TS_DEBUG_FIREWALL_MODE = "nftables";
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
