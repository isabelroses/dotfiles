# if your curious why we have no users, its because the nix iso default provides two users
# nixos and root, both with no passwords so we can change those after we boot into the iso
# https://github.com/NixOS/nixpkgs/blob/90a153e81e7deb0b2ea1466c8a2f515df1974717/nixos/modules/profiles/installation-device.nix#L32
{
  imports = [
    ./boot.nix # boot settings
    ./console.nix # tty configurations
    ./fixes.nix # fixes issues
    ./image.nix # the iso image and its configuration
    ./networking.nix # all access to the outside
    ./nix.nix # nix the package manager configurations
    ./nixpkgs.nix # nixpkgs configurations like unfree packages
    ./programs.nix # programs that we will need to make our NixOS install
    ./space.nix # ways that we save valuable space on the iso
  ];
}
