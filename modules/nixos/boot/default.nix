{
  imports = [
    ./loader.nix # which system loader are we using
    ./generic.nix # generic boot configuration
    ./secure-boot.nix # pretty much what it looks like
  ];
}
