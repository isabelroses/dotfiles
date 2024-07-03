{
  lib,
  config,
  inputs',
  ...
}:
let
  inherit (lib) mkIf mkSecret mkServiceOption;
in
{
  options.garden.services.blahaj = mkServiceOption "blahaj" { };

  config = mkIf config.garden.services.blahaj.enable {
    age.secrets.blahaj-env = mkSecret { file = "blahaj-env"; };

    systemd.services."blahaj" = {
      description = "blahaj";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        EnvironmentFile = config.age.secrets.blahaj-env.path;
        ExecStart = "${lib.getExe inputs'.beapkgs.packages.blahaj}";
        Restart = "always";
      };
    };
  };
}
