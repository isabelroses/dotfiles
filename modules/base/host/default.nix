_: {
  imports = [
    ./activation # activation system for nixos-rebuild
    ./hardware # hardware - bluetooth etc.
    ./os # system configurations
    ./security # keeping the system safe
    ./nix # all nix related configurations

    ./emulation.nix # emulation setup
    ./encryption.nix # keeping my stuff hidden from you strange people
    ./virtualization.nix # docker, QEMU, waydroid etc.
  ];
}
