{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.types) port;
  inherit (self.lib) mkSecret mkService;

  cfg = config.garden.services.qbittorrent;
  inherit (config.garden.services) arr;
in
{

  imports = [
    (mkService "qbittorrent" {
      # the port is qui's, which fronts qbittorrent's own webui at webuiPort
      port = 3019;
      host = "0.0.0.0";
      webuiPort = 4019;
      torrentingPort = 43125;
    })
  ];

  config = mkIf cfg.enable {
    # peers have to reach the torrenting port from anywhere
    networking.firewall.allowedTCPPorts = [
      config.services.qbittorrent.torrentingPort
      cfg.port
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

        inherit (cfg) webuiPort torrentingPort;

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
