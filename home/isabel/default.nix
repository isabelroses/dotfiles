{
  imports = [
    # keep-sorted start
    ./cli # command line interface app confurations
    ./gui # graphical interface app confurations
    ./packages.nix # a top-level list of packages
    ./system # important system environment config
    ./themes # Application themeing
    ./tui # terminal interface app confurations
    # keep-sorted end
  ];
}
