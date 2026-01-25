{
  lib,
  glanceLib,
  srv,
  ...
}:
let
  inherit (lib) singleton;
  inherit (glanceLib) mkBookmarks mkKuma mkGoogleCal;
in
{
  name = "Home";
  width = "slim";

  head-widgets = singleton (mkBookmarks [
    [
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
    ]
    [
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
    ]
    [
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
    ]
  ]);

  columns = [
    {
      size = "full";
      widgets = [
        {
          type = "weather";
          location = "Aberystwyth, United Kingdom";
          units = "metric";
          hour-format = "12h";
        }

        {
          type = "custom-api";
          title = "Mullvad Status";
          cache = "1m";
          url = "https://am.i.mullvad.net/json";
          template = ''
            <div>
              <div>
                <div>
                  {{ $connected := (.JSON.Bool "mullvad_exit_ip") }}
                  {{ $ip := (.JSON.String "ip") }}
                  {{ $city := (.JSON.String "city") }}
                  {{ $country := (.JSON.String "country") }}
                  {{ if $connected }}
                    <div class="color-highlight size-h3">
                      Your VPN is connected!
                      <span class="color-positive">●</span> 
                    </div>
                  {{ else }}
                    <div class="color-highlight size-h3">
                      Your VPN is not connected!
                      <span class="color-negative">●</span> 
                    </div>
                  {{ end }}
                </div>
                <div class="size-h5">{{ $ip }} - {{ $city }}, {{ $country }}</div>
              </div>
            </div>
          '';
        }

        (mkKuma "https://status.isabelroses.com" "meow")
        (mkKuma "https://status.tgirl.cloud" "infra")
      ];
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
        mkGoogleCal
      ];
    }
  ];
}
