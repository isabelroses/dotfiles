{ inputs, ... }:
{
  imports = [ inputs.sops.nixosModules.sops ];

  sops.age = {
    generateKey = true;
    keyFile = "/var/lib/sops-nix/key.txt";
    sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
