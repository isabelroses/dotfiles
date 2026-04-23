{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # disable documentation
  documentation = {
    enable = mkForce false;
    dev.enable = mkForce false;
    doc.enable = mkForce false;
    info.enable = mkForce false;
    nixos.enable = mkForce false;

    man = {
      enable = false;
      man-db.enable = false;
    };
  };

  # don't include nixpkgs in our iso
  system.installer.channel.enable = false;

  environment.defaultPackages = mkForce [ ];

  # enabled by default to be the pager, but i don't use it
  programs.less.enable = mkForce false;
}
