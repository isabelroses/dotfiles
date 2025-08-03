{
  imports = [
    # keep-sorted start
    ./formatter.nix # formatter for nix fmt, via treefmt is a formatter for every language
    ./shell.nix # a dev shell that provieds all that you will need to work
    ./topology # generate a image of the flakes topology
    # keep-sorted end
  ];
}
