{ lib, ... }:
let
  inherit (lib.modules) mkOverride;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types)
    anything
    attrsOf
    nullOr
    port
    str
    submodule
    ;

  # weaker than mkOptionDefault, so a service's own defaults win over these
  fallback = mkOverride 1600;
in
{
  options.garden.services = mkOption {
    type = attrsOf (
      submodule (
        { name, config, ... }:
        {
          freeformType = attrsOf anything;

          options = {
            enable = mkEnableOption "the ${name} service";

            host = mkOption {
              type = nullOr str;
              description = "The address ${name} binds, null if it doesn't bind one";
            };

            port = mkOption {
              type = nullOr port;
              description = "The port ${name} listens on, null if it doesn't listen on one";
            };

            domain = mkOption {
              type = nullOr str;
              description = "The domain ${name} is served at, null if it has none";
            };
          };

          config = {
            # only a service that listens on a port has an address to bind
            host = fallback (if config.port == null then null else "127.0.0.1");
            port = fallback null;
            domain = fallback null;
          };
        }
      )
    );
    default = { };
    description = "The services this host can run";
  };

  imports = [
    # keep-sorted start
    ./arr.nix
    ./atuin.nix
    ./blahaj.nix
    ./borgbackup.nix
    ./exporters
    ./fluent-bit.nix
    ./forgejo.nix
    ./gatus
    ./grafana
    ./home-assistant
    ./immich.nix
    ./jellyfin.nix
    ./kanidm.nix
    ./lethe.nix
    ./loki.nix
    ./mailserver.nix
    ./matrix.nix
    ./nginx.nix
    # ./nixbot.nix
    ./nixpkgs-prs-bot.nix
    ./pds
    ./piper.nix
    ./postgresql.nix
    ./prometheus.nix
    ./prowlarr.nix
    ./qbittorent.nix
    ./quoteit.nix
    ./radarr.nix
    ./redis.nix
    ./snot.nix
    ./sonarr.nix
    ./tranquil.nix
    ./vaultwarden.nix
    ./wakapi.nix
    ./website.nix
    # keep-sorted end
  ];
}
