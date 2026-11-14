{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr path;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.home-assistant;
  hashDir = config.services.home-assistant.configDir;
  thread = cfg.radio != null;
in
{
  options.garden.services.home-assistant =
    mkServiceOption "home-assistant" {
      port = 8123;
      host = "0.0.0.0";
      domain = "home.${config.networking.domain}";
    }
    // {
      radio = mkOption {
        type = nullOr path;
        default = null;
        example = "/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_...-if00-port0";
        description = ''
          Serial path of a Thread RCP radio, e.g. the Sonoff Dongle Plus MG24
          flashed with Thread (RCP) firmware. Setting this enables the
          OpenThread border router.
        '';
      };
    };

  config = mkIf cfg.enable {
    garden.services.postgresql.enable = true;

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [
        # matter finds devices through mdns, and multicast replies never
        # match a conntrack entry so they get dropped without this
        5353
        # matter's operational port, devices send subscription reports here
        # long after any conntrack entry has expired
        5540
      ];
    };

    services = {
      home-assistant = {
        enable = true;

        # there is no add-on store on nixos, so anything extra is either a
        # component here or its own nixos service below
        extraComponents = [
          "default_config"
          "isal"

          # onboarding sets these up, and they fail without their deps
          "analytics"
          "google_translate"
          "met"
          "radio_browser"
          "shopping_list"

          # matter and thread for the ikea devices
          "matter"
          "otbr"
          "thread"

          # watching the server and closet
          "systemmonitor"
          "wake_on_lan"
        ];

        # the recorder needs a driver to talk to postgres
        extraPackages = ps: [ ps.psycopg2 ];

        config = {
          default_config = { };

          # no host means the unix socket, where peer auth lets hass in
          recorder.db_url = "postgresql://@/hass";

          http = {
            server_host = [ cfg.host ];
            server_port = cfg.port;
          };

          # let things made in the ui live alongside the nix config
          "automation ui" = "!include automations.yaml";
          "scene ui" = "!include scenes.yaml";
          "script ui" = "!include scripts.yaml";
        };
      };

      postgresql = {
        ensureDatabases = [ "hass" ];
        ensureUsers = lib.lists.singleton {
          name = "hass";
          ensureDBOwnership = true;
        };
      };

      matter-server = {
        enable = true;

        # one of the PAA root certs on the DCL is malformed, and cryptography
        # 50 throws on it instead of warning. that kills the startup task
        # before the websocket ever binds, while systemd still says active
        # top-level, not python3Packages: only it has the server extras
        package = pkgs.python-matter-server.overridePythonAttrs (oa: {
          patches = (oa.patches or [ ]) ++ [ ./matter-server-skip-invalid-paa.patch ];
        });
      };

      openthread-border-router = mkIf thread {
        enable = true;
        radio = {
          device = cfg.radio;
          # the MG24's thread firmware runs at 460800 with flow control
          baudRate = 460800;
          flowControl = true;
        };
      };
    };

    # home assistant refuses to start if the included files are missing
    systemd.tmpfiles.rules = map (f: "f ${hashDir}/${f} 0644 hash hash") [
      "automations.yaml"
      "scenes.yaml"
      "scripts.yaml"
    ];
  };
}
