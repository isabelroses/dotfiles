{
  imports = [
    ./grub.nix # configurations for grub
    ./none.nix # how do we handle no boot loader
    ./systemd-boot.nix # configurations for systemd boot
  ];
}
