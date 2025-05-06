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
      vikunja.enable = false;
      kanidm.enable = true;
      mailserver.enable = true;

      # web
      nginx.enable = true;
      cloudflared.enable = false;
      headscale.enable = false;

      # dev
      atuin.enable = true;
      forgejo.enable = true;
      wakapi.enable = true;
      plausible.enable = false;

      # social
      akkoma.enable = true;
      nixpkgs-prs-bot = {
        enable = true;
        fedi.enable = true;
        bsky.enable = true;
      };
      matrix.enable = true;
      nextcloud.enable = false;
      syncthing.enable = true;

      # monitoring
      grafana.enable = false;
      prometheus.enable = false;
      loki.enable = false;
      uptime-kuma.enable = false;

      # databases
      influxdb.enable = false;
      mysql.enable = false;
      mongodb.enable = false;
      postgresql.enable = true;
      redis.enable = true;
    };
  };
}
