{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.agenix.homeManagerModules.default ];

  config.age = {
    package = pkgs.rage;
    secretsDir = config.xdg.configHome + "/agenix";
  };
}
