{
  pkgs ? import <nixpkgs> {},
  extras ? "",
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    rustc
    rustfmt
    rust-analyzer
    cargo
    extras
  ];
}
