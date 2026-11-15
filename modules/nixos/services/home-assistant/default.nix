{
  lib,
  pkgs,
  self,
  self',
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr path;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.home-assistant;
  hassDir = config.services.home-assistant.configDir;
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
      interfaces.wpan0.allowedUDPPortRanges = mkIf thread [
        {
          from = 32768;
          to = 60999;
        }
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

          # misc
          "pi_hole"
          "gatus"
        ];

        # the recorder needs a driver to talk to postgres
        extraPackages = ps: [ ps.psycopg2 ];

        customComponents = [
          (config.services.home-assistant.package.python3Packages.callPackage ./cudy-router.nix { })
        ];

        customLovelaceModules = [
          pkgs.home-assistant-custom-lovelace-modules.mushroom
          pkgs.home-assistant-custom-lovelace-modules.mini-graph-card
          self'.legacyPackages.mushroom-strategy
        ];

        config = {
          default_config = { };

          # no host means the unix socket, where peer auth lets hass in
          recorder.db_url = "postgresql://@/hass";

          http = {
            server_host = [ cfg.host ];
            server_port = cfg.port;
          };

          frontend.themes.mushroom_custom =
            let
              c = {
                rosewater = "#f5e0dc";
                pink = "#f5c2e7";
                mauve = "#cba6f7";
                red = "#f38ba8";
                peach = "#fab387";
                yellow = "#f9e2af";
                green = "#a6e3a1";
                teal = "#94e2d5";
                sky = "#89dceb";
                blue = "#89b4fa";
                lavender = "#b4befe";
                text = "#cdd6f4";
                subtext0 = "#a6adc8";
                overlay0 = "#6c7086";
                surface0 = "#313244";
                surface1 = "#45475a";
                base = "#000000";
                mantle = "#010101";
                crust = "#020202";
              };
            in
            {
              modes.dark = { };

              primary-color = c.pink;
              accent-color = c.pink;
              rgb-primary-color = "245, 194, 231";
              rgb-accent-color = "245, 194, 231";
              light-primary-color = c.rosewater;
              dark-primary-color = c.mauve;
              text-primary-color = c.crust;
              text-accent-color = c.crust;

              primary-text-color = c.text;
              secondary-text-color = c.subtext0;
              disabled-text-color = c.overlay0;
              rgb-primary-text-color = "205, 214, 244";

              primary-background-color = c.base;
              secondary-background-color = c.mantle;
              lovelace-background = c.base;
              card-background-color = c.base;
              ha-card-background = c.base;
              # popups and menus need a step up or they vanish into the page
              ha-dialog-surface-background = c.crust;
              mdc-theme-surface = c.crust;

              app-header-background-color = c.base;
              app-header-text-color = c.text;
              sidebar-background-color = c.base;
              sidebar-text-color = c.subtext0;
              sidebar-icon-color = c.subtext0;
              sidebar-selected-text-color = c.pink;
              sidebar-selected-icon-color = c.pink;

              border-color = c.surface0;
              divider-color = c.surface0;
              outline-color = c.surface1;

              state-icon-color = c.lavender;
              state-active-color = c.pink;
              state-on-color = c.pink;
              state-off-color = c.overlay0;
              state-unavailable-color = c.surface1;

              error-color = c.red;
              warning-color = c.peach;
              success-color = c.green;
              info-color = c.blue;

              switch-checked-color = c.pink;
              switch-checked-button-color = c.pink;
              switch-checked-track-color = c.mauve;
              switch-unchecked-button-color = c.overlay0;
              switch-unchecked-track-color = c.surface0;
              paper-slider-knob-color = c.pink;
              paper-slider-active-color = c.pink;
              paper-slider-container-color = c.surface0;

              mush-rgb-state-light = "249, 226, 175"; # yellow
              mush-rgb-red = "243, 139, 168";
              mush-rgb-pink = "245, 194, 231";
              mush-rgb-purple = "203, 166, 247";
              mush-rgb-blue = "137, 180, 250";
              mush-rgb-light-blue = "137, 220, 235";
              mush-rgb-cyan = "137, 220, 235";
              mush-rgb-teal = "148, 226, 213";
              mush-rgb-green = "166, 227, 161";
              mush-rgb-yellow = "249, 226, 175";
              mush-rgb-orange = "250, 179, 135";
              mush-rgb-grey = "108, 112, 134";
              mush-rgb-disabled = "69, 71, 90";

              mush-spacing = "6px";
              mush-title-padding = "12px 12px 6px";
              ha-card-box-shadow = "inset 0px 0px 0px 1px var(--border-color)";
              ha-card-border-color = "rgba(0,0,0,0)";
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
          # the MG24's thread firmware (SL-OPENTHREAD 2.4.4.0) talks 115200,
          # and CTS is never raised so flow control would block every write
          baudRate = 115200;
          flowControl = false;
        };
      };
    };

    systemd.services.matter-server.path = [ self'.legacyPackages.chip-ota-provider-app ];

    systemd.tmpfiles.rules = map (f: "f ${hassDir}/${f} 0644 hass hass") [
      "automations.yaml"
      "scenes.yaml"
      "scripts.yaml"
    ];
  };
}
