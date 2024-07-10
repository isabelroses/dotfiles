{
  nix = {
    # nix gc works slightly differently on darwin, so we need to adjust the
    # interval such that it works properly here.
    gc.interval = {
      Hour = 3;
      Minute = 15;
    };

    # we add more platforms here because of the limited number of darwin
    # maintainers that exist, thus meaning less working packages for darwin.
    settings.extra-platforms = [
      "aarch64-darwin"
      "x86-64-darwin"
    ];
  };

  # we also need to enable the nix-daemon service to ensure that nix is
  # always running in the background.
  services.nix-daemon.enable = true;
}
