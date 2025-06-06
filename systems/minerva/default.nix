{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      headless.enable = true;
      server = {
        enable = true;
        hetzner = {
          enable = true;
          ipv4 = "91.107.198.173";
          ipv6 = "2a01:4f8:c012:2f67::1";
        };
      };
    };

    device = {
      cpu = "amd";
      gpu = null;
    };

    services = {
      anubis.enable = true;
      vaultwarden.enable = true;
      isabelroses-website.enable = true;
      blahaj.enable = true;
      kanidm.enable = true;
      mailserver.enable = true;

      # web
      nginx.enable = true;

      # dev
      atuin.enable = true;
      forgejo.enable = true;
      wakapi.enable = true;

      # social
      akkoma.enable = true;
      nixpkgs-prs-bot = {
        enable = true;
        fedi.enable = true;
        bsky.enable = true;
      };
      matrix.enable = true;
      syncthing.enable = true;

      # databases
      postgresql.enable = true;
      redis.enable = true;
    };
  };
}
