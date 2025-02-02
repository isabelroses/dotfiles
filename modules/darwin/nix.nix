{
  nix = {
    # nix gc works slightly differently on darwin, so we need to adjust the
    # interval such that it works properly here.
    gc.interval = {
      Hour = 3;
      Minute = 15;
    };

    # we cannot use auto-optimise-store so we do this instead
    # https://github.com/NixOS/nix/issues/7273
    optimise.interval = [
      {
        Hour = 3;
        Minute = 45;
      }
    ];

    # we add more platforms here because of the limited number of darwin
    # maintainers that exist, thus meaning less working packages for darwin.
    settings.extra-platforms = [
      "aarch64-darwin"
      "x86-64-darwin"
    ];
  };

  # use 'nix run github:LnL7/nix-darwin#darwin-uninstaller' instead
  system.includeUninstaller = false;
}
