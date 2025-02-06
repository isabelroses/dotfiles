{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkForce;

  template = self.lib.template.xdg;
  vars = template.user config.xdg;
in
{
  home.sessionVariables = vars // {
    GNUPGHOME = mkForce vars.GNUPGHOME;
  };

  xdg.configFile = {
    "npm/npmrc" = template.npmrc;
    "python/pythonrc" = template.pythonrc;
  };
}
