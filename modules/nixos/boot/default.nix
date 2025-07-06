{
  imports = [
    # keep-sorted start
    ./generic.nix # generic boot configuration
    ./loader.nix # which system loader are we using
    ./secure-boot.nix # pretty much what it looks like
    # keep-sorted end
  ];
}
