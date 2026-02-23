{
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
      inherit (osConfig.sops) package;
      defaultSopsFile = "${self}/secrets/${name}.yaml";
      age.sshKeyFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };
  };
}
