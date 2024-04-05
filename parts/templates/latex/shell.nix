{
  mkShell,
  texliveMedium,
  ...
}:
mkShell {
  buildInputs = [
    texliveMedium
  ];
}
