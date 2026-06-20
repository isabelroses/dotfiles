{ lib, ... }:
let
  inherit (lib.modules) mkForce;
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

  environment.defaultPackages = mkForce [ ];

  # enabled by default to be the pager, but i don't use it
  programs.less.enable = mkForce false;

  # removes perl
  services.userborn.enable = true;

  system = {
    # remove perl; we don't need mutable since its a iso
    etc.overlay = {
      enable = true;
      mutable = false;
    };

    # what is this even doing
    extraDependencies = mkForce [ ];

    # don't include nixpkgs in our iso
    installer.channel.enable = false;

    tools = {
      # drop to remove perl
      nixos-generate-config.enable = false;

      # allow rebuilds with run0
      nixos-rebuild.enableRun0Elevation = true;
    };
  };
}
