{
  lib,
  pkgs,
  ...
}: let
  template = import lib.template.xdg "nixos";
in {
  environment =
    {
      variables = template.glEnv;
      etc = {
        inherit (template) pythonrc npmrc;
      };
    }
    // lib.ldTernary pkgs {
      sessionVariables = template.sysEnv;
    } {};
}
