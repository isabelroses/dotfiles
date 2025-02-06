{ lib, self, ... }:
let
  inherit (lib.modules) mkForce;

  template = self.lib.template.xdg;
in
{
  home.sessionVariables = template.sysEnv // {
    GNUPGHOME = mkForce template.sysEnv.GNUPGHOME;
  };

  xdg.configFile = {
    "npm/npmrc" = template.npmrc;
    "python/pythonrc" = template.pythonrc;
  };
}
