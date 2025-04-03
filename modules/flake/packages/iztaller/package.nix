{
  nix,
  gum,
  vim,
  parted,
  nixos-install,
  writeShellApplication,
}:
writeShellApplication {
  name = "iztaller";

  runtimeInputs = [
    nix
    gum
    vim
    parted
    nixos-install
  ];

  text = builtins.readFile ./iztaller.sh;
}
