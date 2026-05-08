{
  lib,
  self,
  name,
  config,
  inputs,
  osConfig,
  ...
}:
{
  imports = [ inputs.sops.homeManagerModules.sops ];

  config = {
    sops = {
      package = lib.mkIf (osConfig ? sops) osConfig.sops.package;
      defaultSopsFile = "${self}/secrets/${name}.yaml";
      age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    };
  };
}
