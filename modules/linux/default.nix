{
  imports = [
    ./gaming # super cool procrastinations related things
    ./hardware # hardware - bluetooth etc.
    ./options # options, for quick configuration
    ./os # system configurations
    ./security # keeping the system safe
    ./services # allows for per-system system services to be enabled

    ./emulation.nix # emulation setup
    ./encryption.nix # keeping my stuff hidden from you strange people
    ./nix.nix # nix settings for nixos only systems
    ./virtualization.nix # docker, QEMU, waydroid etc.
  ];
}
