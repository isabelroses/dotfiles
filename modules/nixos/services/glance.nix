{
  lib,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.glance;
  rdomain = config.networking.domain;

  inherit (lib) mkIf singleton;
  inherit (self.lib) mkServiceOption mkSecret;

  srv = config.garden.services;
in
{
  options.garden.services.glance = mkServiceOption "glance" {
    port = 3028;
    host = "0.0.0.0";
    domain = "dash.${rdomain}";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      glance-key = mkSecret {
        file = "glance";
        key = "secret-key";
      };

      glance-isabel-pass = mkSecret {
        file = "glance";
        key = "isabel-password";
      };
    };

    services = {
      glance = {
        enable = true;

        settings = {
          auth = {
            secret-key = {
              _secret = config.sops.secrets.glance-key.path;
            };
            users.isabel.password = {
              _secret = config.sops.secrets.glance-isabel-pass.path;
            };
          };

          server = {
            proxied = true;
            inherit (cfg) port host;
          };

          theme = {
            background-color = "240 21 15";
            contrast-multiplier = 1.2;
            primary-color = "217 92 83";
            positive-color = "115 54 76";
            negative-color = "347 70 65";
          };

          branding.hide-footer = true;

          pages = [
            {
              name = "Home";
              width = "slim";

              head-widgets = singleton {
                type = "bookmarks";
                groups = [
                  {
                    title = "Public";
                    links = [
                      {
                        title = "Jellyfin";
                        url = "https://tv.isabelroses.com";
                      }
                      {
                        title = "Akkoma";
                        url = "https://akko.isabelroses.com";
                      }
                      {
                        title = "ntfy";
                        url = "https://ntfy.isabelroses.com";
                      }
                      {
                        title = "wakapi";
                        url = "https://wakapi.isabelroses.com";
                      }
                      {
                        title = "Forgejo";
                        url = "https://git.isabelroses.com";
                      }
                      {
                        title = "bookmarks";
                        url = "https://bookmark.isabelroses.com";
                      }
                      {
                        title = "vaultwarden";
                        url = "https://vault.isabelroses.com";
                      }
                      {
                        title = "webmail";
                        url = "https://webmail.isabelroses.com";
                      }
                    ];
                  }
                  {
                    title = "Servarr";
                    links = [
                      {
                        title = "Sonarr";
                        url = "http://192.168.1.135:${toString srv.sonarr.port}";
                      }
                      {
                        title = "Radarr";
                        url = "http://192.168.1.135:${toString srv.radarr.port}";
                      }
                      {
                        title = "Prowlarr";
                        url = "http://192.168.1.135:${toString srv.prowlarr.port}";
                      }
                      {
                        title = "Qbittorrent";
                        url = "http://192.168.1.135:${toString srv.qbittorrent.port}";
                      }
                    ];
                  }
                ];
              };

              columns = [
                {
                  size = "full";
                  widgets = singleton {
                    type = "weather";
                    location = "Aberystwyth, United Kingdom";
                    units = "metric";
                    hour-format = "12h";
                  };
                }
                {
                  size = "full";
                  widgets = [
                    {
                      type = "clock";
                      hour-format = "12h";
                      timezones = [
                        {
                          label = "Local";
                          timezone = "Europe/London";
                        }
                        {
                          label = "Belgium";
                          timezone = "Europe/Brussels";
                        }
                      ];
                    }
                    {
                      type = "calendar";
                      first-day-of-week = "monday";
                    }
                  ];
                }
              ];
            }

            {
              name = "News";
              width = "slim";
              columns = singleton {
                size = "full";
                widgets = [
                  {
                    type = "markets";
                    hide-title = true;
                    markets = [
                      {
                        symbol = "BTC-GBP";
                        name = "Bitcoin";
                      }
                      {
                        symbol = "ETH-GBP";
                        name = "Ethereum";
                      }
                      {
                        symbol = "XMR-GBP";
                        name = "Monero";
                      }
                    ];
                  }
                  {
                    type = "rss";
                    title = "News";
                    style = "detailed-list";
                    feeds = [
                      {
                        name = "Al Jazeera";
                        url = "https://www.aljazeera.com/xml/rss/all.xml";
                      }
                      {
                        name = "BBC News";
                        url = "http://feeds.bbci.co.uk/news/rss.xml";
                      }
                      {
                        name = "The Guardian";
                        url = "https://www.theguardian.com/uk/rss";
                      }
                    ];
                  }
                ];
              };
            }
          ];
        };
      };

      cloudflared.tunnels.${config.networking.hostName} = {
        ingress.${cfg.domain} = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
