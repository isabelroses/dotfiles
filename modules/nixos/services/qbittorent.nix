{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.qbittorrent;
  inherit (config.garden.services) arr;
in
{
  options.garden.services.qbittorrent = mkServiceOption "qbittorrent" {
    port = 3019;
    host = "0.0.0.0";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      cfg.port
      config.services.qbittorrent.torrentingPort
    ];

    sops.secrets.qui = mkSecret {
      file = "qui";
      key = "qui";
    };

    services = {
      qui = {
        enable = true;
        secretFile = config.sops.secrets.qui.path;
        settings = {
          inherit (cfg) host port;
          checkForUpdates = false;
        };
      };

      qbittorrent = {
        enable = true;
        group = arr.mediaGroup;

        webuiPort = 4019;
        torrentingPort = 43125;

        serverConfig = {
          LegalNotice.Accepted = true;

          BitTorrent.Session = {
            BTProtocol = "TCP";
            DHTEnabled = true;
            LSDEnabled = false;
            PeXEnabled = true;
            QueueingSystemEnabled = false;

            # sorting
            DefaultSavePath = "/media/downloads";
            DisableAutoTMMByDefault = false;
            DisableAutoTMMTriggers = {
              CategorySavePathChanged = false;
              DefaultSavePathChanged = false;
            };
          };

          Core.AutoDeleteAddedTorrentFile = "IfAdded";

          # i will handle this myself lol
          Network.PortForwardingEnabled = false;

          Preferences.WebUI = {
            LocalHostAuth = false;

            # generate with <https://codeberg.org/feathecutie/qbittorrent_password>
            Password_PBKDF2 = "@ByteArray(2PRai2N/GL+Lt+VDdda0kw==:X4+iM6WwTPXExbBwJGcrHqxVsEN0cBxrhACiTMbEeQ6RjTdbfnJSB+CyTn3r1iJzEMMa0/XZzq2U1cG4O6AZZg==)";
          };
        };
      };
    };
  };
}
