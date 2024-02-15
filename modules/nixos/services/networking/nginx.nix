{
  lib,
  config,
  ...
}: let
  cfg = config.modules.services.networking.nginx;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    networking.domain = cfg.domain;

    security = {
      acme = {
        acceptTerms = true;
        defaults.email = "isabel@${cfg.domain}";

        certs.${cfg.domain} = {
          extraDomainNames = [
            "*.${cfg.domain}"
          ];
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets."cloudflare-cert-api".path;
        };
      };
    };

    users.users.nginx.extraGroups = ["acme"];

    services.nginx = {
      enable = true;
      commonHttpConfig = ''
        # real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options nosniff;
      '';

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;

      sslCiphers = "EECDH+aRSA+AESGCM:EDH+aRSA:EECDH+aRSA:+AES256:+AES128:+SHA1:!CAMELLIA:!SEED:!3DES:!DES:!RC4:!eNULL";
      sslProtocols = "TLSv1.3 TLSv1.2";
    };
  };
}
