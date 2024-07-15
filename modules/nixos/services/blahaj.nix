{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib) template;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;
in
{
  options.garden.services.blahaj = mkServiceOption "blahaj" { };

  config = mkIf config.garden.services.blahaj.enable {
    age.secrets.blahaj-env = mkSecret { file = "blahaj-env"; };

    users = {
      groups.blahaj = { };

      users.blahaj = {
        isSystemUser = true;
        createHome = false;
        group = "blahaj";
      };
    };

    systemd = {
      timers."blahaj-nixpkgs" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30m";
          OnUnitActiveSec = "30m";
          Unit = "blahaj-nixpkgs.service";
        };
      };

      services = {
        "blahaj" = {
          description = "blahaj";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            User = "blahaj";
            Group = "blahaj";
            ReadWritePaths = [ "/srv/storage/blahaj/nixpkgs" ];
            EnvironmentFile = config.age.secrets.blahaj-env.path;
            ExecStart = getExe inputs'.beapkgs.packages.blahaj;
            Restart = "always";
          } // template.systemd;
        };

        "blahaj-nixpkgs" = {
          description = "blahaj update nixpkgs";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          script = ''
            ${getExe pkgs.git} -c safe.directory=/srv/storage/blahaj/nixpkgs -C /srv/storage/blahaj/nixpkgs pull origin master
          '';

          serviceConfig = {
            Type = "oneshot";
            User = "blahaj";
            Group = "blahaj";
            ReadWritePaths = [ "/srv/storage/blahaj/nixpkgs" ];
          } // template.systemd;
        };
      };
    };
  };
}
