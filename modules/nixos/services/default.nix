{
  imports = [
    # system services
    # e.g. thermald, for monitoring CPU temperature
    ./system

    # services that a server may provide
    # e.g. nextcloud a web application
    ./databases
    ./dev
    ./media
    ./monitoring
    ./networking
    ./blahaj.nix
    ./kanidm.nix
    ./mailserver.nix
    ./mediawiki.nix
    ./vaultwarden.nix
    ./vikunja.nix
    ./website.nix
  ];
}
