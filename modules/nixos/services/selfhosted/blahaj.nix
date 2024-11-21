{
  lib,
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

    systemd.services = {
      blahaj = {
        description = "blahaj";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = "blahaj";
          Group = "blahaj";
          EnvironmentFile = config.age.secrets.blahaj-env.path;
          ExecStart = getExe inputs'.beapkgs.packages.blahaj;
          Restart = "always";
        } // template.systemd;
      };
    };
  };
}
