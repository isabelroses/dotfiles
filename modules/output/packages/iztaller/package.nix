{
  lib,
  nix,
  gum,
  vim,
  parted,
  nixfmt,
  writeShellApplication,
}:
writeShellApplication {
  name = "iztaller";

  runtimeInputs = [
    nix
    gum
    vim
    parted
    nixfmt
  ];

  text = builtins.readFile ./iztaller.sh;

  meta.platforms = lib.platforms.linux;
}
