{
  self',

  writeShellApplication,
  toot,
}:
writeShellApplication {
  name = "nixpkgs-fedibot";
  text = builtins.readFile ./script.sh;
  runtimeInputs = [
    toot
    self'.packages.nixpkgs-prs
  ];
}
