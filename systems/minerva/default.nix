{
  imports = [
    ./hardware.nix
    ./relay.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;

      hetzner.enable = true;
    };

    # AMD EPYC-Rome, no gpu
    device.cpu = "vm-amd";

    services = {
      vaultwarden.enable = true;
      isabelroses-website.enable = true;
      blahaj.enable = true;
      quoteit.enable = true;
      kanidm.enable = true;
      mailserver.enable = true;
      borgbackup.enable = true;

      # web
      nginx.enable = true;

      # dev
      atuin.enable = true;
      forgejo.enable = true;
      snot.enable = true;
      wakapi.enable = true;

      # social
      nixpkgs-prs-bot = {
        enable = true;
        bsky.enable = true;
      };
      matrix.enable = true;
      tranquil.enable = true;

      # databases
      postgresql.enable = true;
      redis.enable = true;
    };
  };
}
