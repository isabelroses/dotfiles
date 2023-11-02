{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.networking) domain;
  cfg = config.modules.services.dns.adguardhome;
in {
  services = mkIf cfg.enable {
    adguardhome = {
      enable = true;
      host = "0.0.0.0";
      port = 6902;
      openFirewall = false;
      mutableSettings = true;
      settings = {
        dns = {
          bootstrap_dns = "45.11.45.11";
          parental_enabled = false;
          safesearch_enabled = false;
          safebrowsing_enabled = false;
          enable_dnssec = true;
          bind_host = "0.0.0.0";
          bind_hosts = [
            "0.0.0.0"
          ];
          upstream_dns = [
            "1.1.1.1"
            "1.0.0.1"
            "https://dns.quad9.net/dns-query"
            "9.9.9.9"
            "https://doh.dns.sb/dns-query"
            "https://mozilla.cloudflare-dns.com/dns-query"
          ];
          trusted_proxies = [
            "103.21.244.0/22"
            "103.22.200.0/22"
            "103.31.4.0/22"
            "104.16.0.0/13"
            "104.24.0.0/14"
            "108.162.192.0/18"
            "131.0.72.0/22"
            "141.101.64.0/18"
            "162.158.0.0/15"
            "172.64.0.0/13"
            "173.245.48.0/20"
            "188.114.96.0/20"
            "190.93.240.0/20"
            "197.234.240.0/22"
            "198.41.128.0/17"
            "2400:cb00::/32"
            "2606:4700::/32"
            "2803:f800::/32"
            "2405:b500::/32"
            "2405:8100::/32"
            "2a06:98c0::/29"
            "2c0f:f248::/32"
          ];
        };
        tls = {
          enabled = true;
          force_https = true;
          server_name = "dns.${domain}";
          port_https = 5300;
          port_dns_over_tls = 0;
          port_dns_over_quic = 0;
        };
        filters = [
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt";
            name = "Actually Legitimate URL Shortener Tool";
          }
          {
            enabled = true;
            url = "https://filters.adtidy.org/extension/ublock/filters/14_optimized.txt";
            name = "Adguard Annoyances";
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_15_DnsFilter/filter.txt";
            name = "Adguard DNS";
          }
        ];
      };
    };

    nginx.virtualHosts."dns.${domain}".locations."/".proxyPass = "http://127.0.0.1:5300";
  };
}
