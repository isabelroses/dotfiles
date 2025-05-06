{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib.secrets) mkSecret;
in
{
  options.garden.services.blahaj = mkServiceOption "blahaj" { };

  config = mkIf config.garden.services.blahaj.enable {
    age.secrets.blahaj-env = mkSecret { file = "blahaj-env"; };

    services.blahaj = {
      enable = true;
      environmentFile = config.age.secrets.blahaj-env.path;
    };
  };
}
