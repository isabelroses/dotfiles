{
  imports = [
    ./boot.nix # boot settings
    ./console.nix # tty configurations
    ./fixes.nix # fixes issues
    ./image.nix # the iso image and its configuration
    ./networking.nix # all access to the outside
    ./nix.nix # nix the package manager configurations
    ./programs.nix # programs that we will need to make our NixOS install
    ./space.nix # ways that we save valuable space on the iso
    ./users.nix # who is on this iso
  ];
}
