{ inputs, inputs', ... }:
{
  imports = [ inputs.sops.nixosModules.sops ];

  sops = {
    # https://github.com/Mic92/sops-nix/issues/908
    package = inputs'.sops.packages.sops-install-secrets.overrideAttrs {
      enableParallelBuilding = false;
      enableParallelChecking = false;
      enableParallelInstalling = false;
      postInstall = "";
      outputs = [ "out" ];
    };

    age = {
      sshKeyFile = "/etc/ssh/ssh_host_ed25519_key";

      # don't load extra keys
      sshKeyPaths = [ ];
    };

    # don't load extra keys
    gnupg.sshKeyPaths = [ ];
  };
}
