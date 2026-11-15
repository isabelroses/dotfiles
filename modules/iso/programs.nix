{
  lib,
  pkgs,
  self',
  ...
}:
{
  # disable all installer tools and only bring the ones that we explicitly need
  # for installing or debugging
  system = {
    disableInstallerTools = true;

    tools = {
      nixos-enter.enable = true;
      nixos-install.enable = true;

      nixos-rebuild = {
        enable = true;
        enableRun0Elevation = true;
      };
    };
  };

  # we only need a basic git install
  programs.git.package = pkgs.gitMinimal;

  # needed packages for the installer
  environment.systemPackages = [
    self'.legacyPackages.iztaller
  ];

  # the upstream installer profile adds one overlay to trim mbrola voices for
  # speechd; drop it since i remove speechd anyways.
  # <https://github.com/NixOS/nixpkgs/blob/b75227dfa10fe49fd0cae2f5ef82e97babd16c44/nixos/modules/profiles/installation-device.nix#L136-L144>
  nixpkgs.overlays = lib.modules.mkForce [ ];
}
