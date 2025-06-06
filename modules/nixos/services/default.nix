{
  imports = [
    # databases
    ./postgresql.nix
    ./redis.nix

    # dev
    ./atuin.nix
    ./forgejo.nix
    ./wakapi.nix

    # media
    ./akkoma
    ./nixpkgs-prs-bot.nix
    ./matrix.nix
    ./syncthing.nix

    # monitoring
    ./grafana
    ./loki.nix
    ./prometheus.nix
    ./uptime-kuma.nix

    # networking
    ./headscale.nix
    ./nginx.nix

    # nix builds
    ./attic.nix
    # ./buildbot.nix

    # misc
    ./anubis.nix
    ./blahaj.nix
    ./kanidm.nix
    ./mailserver.nix
    ./mediawiki.nix
    ./vaultwarden.nix
    ./vikunja.nix
    ./website.nix
  ];
}
