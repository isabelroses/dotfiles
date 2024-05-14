{
  nix = {
    gc.interval = {
      Hour = 3;
      Minute = 15;
    };

    settings.extra-platforms = [
      "aarch64-darwin"
      "x86-64-darwin"
    ];
  };

  services.nix-daemon.enable = true;
}
