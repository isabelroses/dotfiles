{
  self,
  name,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.sops.homeManagerModules.sops ];

  config = {
    sops = {
      defaultSopsFile = "${self}/secrets/${name}.yaml";
      age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
  };
}
