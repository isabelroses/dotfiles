{
  nix,
  gum,
  vim,
  parted,
  nixos-install-tools,
  writeShellApplication,
}:
writeShellApplication {
  name = "iznix-install";

  runtimeInputs = [
    nix
    gum
    vim
    parted
    nixos-install-tools # for nixos-install
  ];

  text = builtins.readFile ./iznix-install.sh;
}
