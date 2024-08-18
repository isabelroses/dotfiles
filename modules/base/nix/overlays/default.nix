{
  imports = [
    # this file exists to work around issues with nixpkgs that may arise
    # hopefully that means its empty a lot
    ./fixes.nix

    # our custom overlays start from this point on
    ./lix.nix
    ./no-desktop.nix
  ];
}
