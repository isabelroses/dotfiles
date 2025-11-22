{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkSystemSecret;
in
{
  # FIXME: this seems to fail to fail on certain systems
  #
  # options = {
  #   security.acme.certs = mkOption {
  #     type = types.attrsOf (
  #       types.submodule (cfg: {
  #         freeformType = types.attrsOf types.anything;
  #
  #         config = {
  #           dnsProvider = "cloudflare";
  #           credentialsFile = config.sops.secrets."lego-${cfg.config.dnsProvider}".path;
  #           webroot = null;
  #         };
  #       })
  #     );
  #   };
  # };

  config = mkIf config.garden.services.nginx.enable {
    sops.secrets = {
      lego-cloudflare = mkSystemSecret {
        file = "lego";
        key = "cloudflare";
        owner = "nginx";
        group = "nginx";
      };

      lego-bunny = mkSystemSecret {
        file = "lego";
        key = "bunny";
        owner = "nginx";
        group = "nginx";
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "isabel@isabelroses.com";
    };
  };
}
