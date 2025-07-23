{ inputs, ... }:
{
  imports = [ inputs.sops.nixosModules.sops ];

  sops = {
    age = {
      sshKeyFile = "/etc/ssh/ssh_host_ed25519_key";

      # don't load extra keys
      sshKeyPaths = [ ];
    };

    # don't load extra keys
    gnupg.sshKeyPaths = [ ];
  };
}
