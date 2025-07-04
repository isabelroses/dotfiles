{
  nix,
  gum,
  vim,
  parted,
  nixos-install-tools,
  writeShellApplication,
}:
writeShellApplication {
  name = "iztaller";

  runtimeInputs = [
    nix
    gum
    vim
    parted
    nixos-install-tools
  ];

  text = builtins.readFile ./iztaller.sh;
}
