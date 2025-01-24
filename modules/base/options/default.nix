{
  imports = [
    ./environment
    ./altered.nix # this file is used to gradually remove options
    ./device.nix
    ./meta.nix
  ];
}
