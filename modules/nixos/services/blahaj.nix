{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;
in
{
  options.garden.services.blahaj = mkServiceOption "blahaj" { };

  config = mkIf config.garden.services.blahaj.enable {
    age.secrets.blahaj-env = mkSystemSecret { file = "blahaj-env"; };

    services = {
      blahaj = {
        enable = true;
        environmentFile = config.age.secrets.blahaj-env.path;
      };

      nginx.virtualHosts."blahaj.isabelroses.com" = {
        locations."/".proxyPass = "http://127.0.0.1:3000";
      };
    };
  };
}
