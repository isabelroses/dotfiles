{
  imports = [
    ./boot # boot and bootloader configurations
    ./environment # system environment
    ./fs # file system confiurations
    ./gaming # super cool procrastinations related things
    ./hardware # hardware - bluetooth etc.
    ./networking # networking
    ./programs # programs that are needed on nixos systems, shared system wide
    ./security # keeping the system safe
    ./services # allows for per-system system services to be enabled

    ./auto-update.nix # auto update settings
    ./catppuccin.nix # our system theming
    ./emulation.nix # emulation setup
    ./encryption.nix # keeping my stuff hidden from you strange people
    ./nix.nix # nix settings for nixos only systems
    ./perless.nix # perless specific configurations
    ./remote-modules.nix # modules that are not in this repo, and don't have a nice place to be imported in
    ./topology.nix # our systems topology
    ./virtualization.nix # docker, QEMU, waydroid etc.
  ];
}
