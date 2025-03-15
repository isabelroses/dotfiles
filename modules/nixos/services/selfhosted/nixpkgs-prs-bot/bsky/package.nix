{
  self',

  writeShellApplication,
  # bsky,
  callPackage,
}:
writeShellApplication {
  name = "nixpkgs-bskybot";
  text = builtins.readFile ./script.sh;
  runtimeInputs = [
    (callPackage ./bsky-package.nix { })
    self'.packages.nixpkgs-prs
  ];
}
