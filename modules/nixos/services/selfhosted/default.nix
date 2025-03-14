{
  imports = [
    # databases
    ./influxdb.nix
    ./mongodb.nix
    ./postgresql.nix
    ./mysql.nix
    ./redis.nix

    # dev
    ./atuin.nix
    ./forgejo.nix
    ./plausible.nix
    ./wakapi.nix

    # media
    ./akkoma
    ./nixpkgs-fedibot
    ./jellyfin.nix
    ./matrix.nix
    ./nextcloud.nix
    ./photoprism.nix
    ./syncthing.nix

    # monitoring
    ./grafana
    ./loki.nix
    ./prometheus.nix
    ./uptime-kuma.nix

    # networking
    ./cloudflared.nix
    ./headscale.nix
    ./nginx.nix

    # nix builds
    ./attic.nix
    # ./buildbot.nix

    # misc
    ./blahaj.nix
    ./kanidm.nix
    ./mailserver.nix
    ./mediawiki.nix
    ./vaultwarden.nix
    ./vikunja.nix
    ./website.nix
  ];
}
