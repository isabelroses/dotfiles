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
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib.secrets) mkSecret;

  cfg = config.garden.services.nixpkgs-fedibot;

  package = pkgs.callPackage ./package.nix { inherit self'; };
in
{
  options.garden.services.nixpkgs-fedibot = mkServiceOption "nixpkgs-fedibot" {
    inherit (config.garden.services.akkoma) domain;
  };

  config = mkIf cfg.enable {
    age.secrets.nixpkgs-fedibot-env = mkSecret {
      file = "nixpkgs-fedibot-env";
      owner = "nixpkgs-fedibot";
      group = "nixpkgs-fedibot";
    };

    users = {
      users.nixpkgs-fedibot = {
        isSystemUser = true;
        home = "/var/lib/nixpkgs-fedibot";
        createHome = true;
        description = "nixpkgs fedibot";
        group = "nixpkgs-fedibot";
      };

      groups.nixpkgs-fedibot = { };
    };

    systemd = {
      timers.nixpkgs-fedi-bot = {
        description = "post to fedi every night";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 00:05:00 UTC";
          Persistent = true;
        };
      };

      services.nixpkgs-fedibot = {
        description = "nixpkgs prs fedi bot";
        after = [ "network.target" ];
        path = [ package ];

        environment = {
          FEDI_INSTANCE = cfg.domain;
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = getExe package;
          User = "nixpkgs-fedibot";
          Group = "nixpkgs-fedibot";
          EnvironmentFile = config.age.secrets.nixpkgs-fedibot-env.path;
          ReadWritePaths = [ "/var/lib/nixpkgs-fedibot" ];
        } // template.systemd;
      };
    };
  };
}
