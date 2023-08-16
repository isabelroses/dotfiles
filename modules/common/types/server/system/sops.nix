{inputs, ...}: {
  imports = [inputs.sops.nixosModules.sops];
  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = let
      secretsPath = "/var/lib/sops/secrets";
      mailserverPath = secretsPath + "/mailserver";
    in {
      cloudflared-hydra.path = secretsPath + "/cloudflared/hydra";

      # mailserver
      mailserver-isabel.path = mailserverPath + "/isabel";
      mailserver-gitea.path = mailserverPath + "/gitea";
      mailserver-vaultwarden.path = mailserverPath + "/vaultwarden";

      # vaultwarden
      vaultwarden-env.path = secretsPath + "/vaultwarden/env";
    };
  };
}
