{
  lib,
  pkgs,
  self,
  self',
  config,
  ...
}:
let
  inherit (self.lib) template;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib.secrets) mkSecret;

  cfg = config.garden.services.nixpkgs-prs-bot;

  package-fedi = pkgs.callPackage ./fedi/package.nix { inherit self'; };
  package-bsky = pkgs.callPackage ./bsky/package.nix { inherit self'; };

  common = {
    Type = "oneshot";
    User = "nixpkgs-prs-bot";
    Group = "nixpkgs-prs-bot";
    ReadWritePaths = [ "/var/lib/nixpkgs-prs-bot" ];
  } // template.systemd;
in
{
  options.garden.services.nixpkgs-prs-bot = mkServiceOption "nixpkgs-prs-bot" {
    inherit (config.garden.services.akkoma) domain;

    extraConfig = {
      fedi.enable = mkEnableOption "fedi";
      bsky.enable = mkEnableOption "bsky";
    };
  };

  config = mkIf cfg.enable {
    age.secrets = {
      nixpkgs-prs-bot-fedi = mkSecret {
        file = "nixpkgs-prs-bot/fedi";
        owner = "nixpkgs-prs-bot";
        group = "nixpkgs-prs-bot";
      };

      nixpkgs-prs-bot-bsky = mkSecret {
        file = "nixpkgs-prs-bot/bsky";
        owner = "nixpkgs-prs-bot";
        group = "nixpkgs-prs-bot";
      };
    };

    users = {
      users.nixpkgs-prs-bot = {
        isSystemUser = true;
        home = "/var/lib/nixpkgs-prs-bot";
        createHome = true;
        description = "nixpkgs prs bot";
        group = "nixpkgs-prs-bot";
      };

      groups.nixpkgs-prs-bot = { };
    };

    systemd = {
      timers.nixpkgs-prs = {
        description = "post to fedi/bsky every night";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 00:05:00 UTC";
          Persistent = true;
        };
      };

      services = mkMerge [
        (mkIf cfg.fedi.enable {
          nixpkgs-prs-fedibot = {
            description = "nixpkgs prs fedi bot";
            after = [ "network.target" ];
            path = [ package-fedi ];

            environment = {
              FEDI_INSTANCE = cfg.domain;
            };

            serviceConfig = {
              ExecStart = getExe package-fedi;
              EnvironmentFile = config.age.secrets.nixpkgs-prs-bot-fedi.path;
            } // common;
          };
        })

        (mkIf cfg.bsky.enable {
          nixpkgs-prs-bskybot = {
            description = "nixpkgs prs bsky bot";
            after = [ "network.target" ];
            path = [ package-bsky ];

            serviceConfig = {
              ExecStart = getExe package-bsky;
              EnvironmentFile = config.age.secrets.nixpkgs-prs-bot-bsky.path;
            } // common;
          };
        })
      ];
    };
  };
}
