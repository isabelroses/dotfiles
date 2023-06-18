{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./system.nix
    ./hardware-configuration.nix
  ];
}
