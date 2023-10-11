_: {
  imports = [
    ./activation # activation system for nixos-rebuild
    ./emulation # emulation setup
    ./encryption # keeping my stuff hidden from you strange people
    ./hardware # hardware - bluetooth etc.
    ./media # sound and video
    ./nix # nix the package manger options
    ./os # system configurations
    ./security # keeping the system safe
    ./smb # host and recive smb shares TODO move
    ./virtualization # docker, QEMU, waydroid etc.
  ];
}
