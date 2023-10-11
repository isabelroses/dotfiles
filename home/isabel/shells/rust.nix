{
  pkgs ? import <nixpkgs> {},
  extras ? "",
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    rustc
    rustfmt
    sccache
    rust-analyzer
    cargo
    openssl
    extras
  ];

  shellHook = ''
    export OPENSSL_DIR="${pkgs.openssl.dev}"
    export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
  '';
}
