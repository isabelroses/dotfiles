{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) enum;
in
{
  imports = [
    ./grub.nix # configurations for grub
    ./none.nix # how do we handle no boot loader
    ./systemd-boot.nix # configurations for systemd boot
  ];

  options.garden.system.boot.loader = mkOption {
    type = enum [
      "none"
      "grub"
      "systemd-boot"
    ];
    default = "none";
    description = "The bootloader that should be used for the device.";
  };
}
