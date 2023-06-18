{
  pkgs ? import <nixpkgs> {},
  extras ? "",
}: {
  pkgs.mkShell = {
    nativeBuildInputs = with pkgs; [
      gjs
      gtk3
      pango
      cairo
      harfbuzz
      gdk-pixbuf
      glib
    ];
  };
}
