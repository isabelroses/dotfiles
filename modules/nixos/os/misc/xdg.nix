{ lib, ... }:
let
  template = import lib.template.xdg "nixos";
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
