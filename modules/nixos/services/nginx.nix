{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkOption
    mkDefault
    ;
  inherit (self.lib) mkServiceOption mkSystemSecret;

  cfg = config.garden.services.nginx;
in
{
  options = {
    # getchoo you are so cool for teaching me this!
    # https://github.com/getchoo/borealis/blob/6e5ad4fb14a0de172c64e0d6a9d6f63ed7df88e6/modules/nixos/mixins/nginx.nix#L5
    services.nginx.virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }:
          {
            freeformType = types.attrsOf types.anything;

            config = {
              quic = mkDefault true;
              forceSSL = mkDefault true;
              enableACME = mkDefault false;
              useACMEHost = mkDefault cfg.domain;
            };
          }
        )
      );
    };

    garden.services.nginx = mkServiceOption "nginx" {
      domain = "isabelroses.com";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.cloudflare-cert-api = mkSystemSecret {
      file = "cloudflare";
      key = "cert-api";
      owner = "nginx";
      group = "nginx";
    };

    networking = { inherit (cfg) domain; };

    security.acme = {
      acceptTerms = true;
      defaults.email = "isabel@isabelroses.com";

      certs.${cfg.domain} = {
        extraDomainNames = [ "*.${cfg.domain}" ];
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.cloudflare-cert-api.path;
      };
    };

    users.users.nginx.extraGroups = [ "acme" ];

    services.nginx = {
      enable = true;
      statusPage = true; # For monitoring scraping.

      package = pkgs.nginxQuic.override { withKTLS = true; };

      commonHttpConfig = ''
        # real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options nosniff;
      '';

      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      experimentalZstdSettings = true;

      sslCiphers = "EECDH+aRSA+AESGCM:EDH+aRSA:EECDH+aRSA:+AES256:+AES128:+SHA1:!CAMELLIA:!SEED:!3DES:!DES:!RC4:!eNULL";
      sslProtocols = "TLSv1.3 TLSv1.2";
    };
  };
}
