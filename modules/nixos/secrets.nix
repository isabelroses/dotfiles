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

    # do muh stuff
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # don't load extra keys
    gnupg.sshKeyPaths = [ ];
  };
}
