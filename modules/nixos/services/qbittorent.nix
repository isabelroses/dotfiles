{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) port;
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.qbittorrent;
  inherit (config.garden.services) arr;
in
{
  # port is qui's, which fronts qbittorrent's own webui
  options.garden.services.qbittorrent = mkServiceOption "qbittorrent" { port = 3019; } // {
    webuiPort = mkOption {
      type = port;
      default = 4019;
      description = "The port for qbittorrent's own webui, which qui talks to";
    };

    torrentingPort = mkOption {
      type = port;
      default = 43125;
      description = "The port peers reach qbittorrent on";
    };
  };

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
