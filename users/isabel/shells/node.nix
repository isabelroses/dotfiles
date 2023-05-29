{
  pkgs ? import <nixpkgs> {},
  extras ? "",
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nodejs
    nodePackages.typescript
    extras
  ];
}