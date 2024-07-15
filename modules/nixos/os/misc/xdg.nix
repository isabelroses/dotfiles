{ lib, ... }:
let
  template = lib.template.xdg;
in
{
  environment = {
    variables = template.glEnv;
    sessionVariables = template.sysEnv;
    etc = {
      inherit (template) pythonrc npmrc;
    };
  };
}
