{
  # nix gc works slightly differently on darwin, so we need to adjust the
  # interval such that it works properly here.
  nix.gc.interval = {
    Hour = 3;
    Minute = 15;
  };
}
