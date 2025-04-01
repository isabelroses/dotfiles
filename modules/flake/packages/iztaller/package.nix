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
    nixos-install-tools # for nixos-install
  ];

  text = builtins.readFile ./iztaller.sh;
}
