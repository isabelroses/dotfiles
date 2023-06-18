{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./settings.nix
    ./hardware-configuration.nix
  ];
}
