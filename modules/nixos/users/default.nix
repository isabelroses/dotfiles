{
  imports = [
    # keep-sorted start
    ./isabel.nix
    ./robin.nix
    ./root.nix
    # keep-sorted end
  ];

  config = {
    # disable the ability to modify users outside of the nixos configuration
    users.mutableUsers = false;
  };
}
