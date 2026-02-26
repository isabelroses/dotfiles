{
  lixPackageSets,
  gum,
  vim,
  parted,
  nixos-install-tools,
  writeShellApplication,
}:
writeShellApplication {
  name = "iztaller";

  runtimeInputs = [
    lixPackageSets.git.lix
    gum
    vim
    parted
    nixos-install-tools
  ];

  text = builtins.readFile ./iztaller.sh;
}
