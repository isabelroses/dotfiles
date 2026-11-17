{ inputs, ... }:
{
  imports = [ inputs.sops.nixos ];

  sops = {
    # do muh stuff
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # don't load extra keys
    gnupg.sshKeyPaths = [ ];
  };
}
