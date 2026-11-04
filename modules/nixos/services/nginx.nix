{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault mkMerge;
  inherit (lib.options) mkOption;
  inherit (lib) types;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.nginx;
in
{
  options = {
    # getchoo you are so cool for teaching me this!
    # https://github.com/getchoo/borealis/blob/6e5ad4fb14a0de172c64e0d6a9d6f63ed7df88e6/modules/nixos/mixins/nginx.nix#L5
    services.nginx.virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule (_: {
          freeformType = types.attrsOf types.anything;

          config = {
            quic = mkDefault true;
            forceSSL = mkDefault true;
            enableACME = mkDefault true;
            extraConfig = "if ($ai_crawler) { return 403; }";
          };
        })
      );
    };

    garden.services.nginx = mkServiceOption "nginx" {
      domain = "isabelroses.com";
    };
  };

  config = mkMerge [
    { networking = { inherit (cfg) domain; }; }

    (mkIf cfg.enable {
      users.users.nginx.extraGroups = [ "acme" ];

      security.acme = {
        acceptTerms = true;
        defaults.email = "isabel@isabelroses.com";
      };

      networking.firewall = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [
          80
          443
        ];
      };

      services.nginx = {
        enable = true;
        statusPage = true; # For monitoring scraping.

        # `proxy_cache static;` in a location caches what upstream marks
        # cacheable, or 200s for a day when it says nothing
        proxyCachePath.static = {
          enable = true;
          keysZoneName = "static";
          maxSize = "2g";
          inactive = "7d";
        };

        commonHttpConfig = ''
          proxy_cache_valid 200 1d;
          proxy_cache_use_stale error timeout updating http_502 http_503 http_504;
          proxy_cache_lock on;

          # crawlers that train models or resell scraped data
          map $http_user_agent $ai_crawler {
            default 0;
            "~*(GPTBot|ChatGPT-User|OAI-SearchBot|ClaudeBot|Claude-Web|anthropic-ai|CCBot|Bytespider|Amazonbot|meta-externalagent|FacebookBot|PerplexityBot|cohere-ai|Diffbot|ImagesiftBot|Omgilibot|Timpibot|PetalBot|YouBot|AI2Bot|Scrapy)" 1;
          }

          add_header 'Referrer-Policy' 'origin-when-cross-origin';
          add_header Content-Security-Policy "frame-ancestors 'self'" always;
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

        # undo the the changes we made to `services.nginx.virtualHosts`
        virtualHosts.localhost = {
          forceSSL = false;
          enableACME = false;
        };
      };
    })
  ];
}
