{ config, inputs, ... }:
{
  imports = [ inputs.sops.homeManagerModules.sops ];

  config = {
    sops.age = {
      sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
  };
}
