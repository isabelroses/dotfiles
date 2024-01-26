_: {
  imports = [
    ./activation # activation system for nixos-rebuild
    ./hardware # hardware - bluetooth etc.
    ./os # system configurations
    ./security # keeping the system safe

    ./emulation.nix # emulation setup
    ./encryption.nix # keeping my stuff hidden from you strange people
    ./nix.nix # nix the package manger options
    ./virtualization.nix # docker, QEMU, waydroid etc.
  ];
}
