{ inputs, ... }:
{
  imports = [ inputs.sops.nixosModules.sops ];

  sops = {
    # do muh stuff
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # don't load extra keys
    gnupg.sshKeyPaths = [ ];
  };
}
