{ pkgs, ... }:
let
  inherit (pkgs) ibm-plex;

  fnts = [
    "Symbols Nerd Font"
# fallbacks
    "Noto Sans Symbols"
    "Noto Sans Symbols2"
  ];
in
{
  config = {
    garden.packages = {
      ibm-plex = ibm-plex.override {
        families = [
          "serif" "sans" "sans-kr" "sans-jp"
          "mono" "math"
        ];
      };

      inherit (pkgs.tex-gyre) schola;
      inherit (pkgs) cozette;
    };

    fonts.fontconfig.defaultFonts = {
      serif = [
        "TeX Gyre Schola"
        "IBM Plex Serif"
      ] ++ fnts;

      sansSerif = [
        "IBM Plex Sans" "IBM Plex Sans KR" "IBM Plex Sans JP"
      ] ++ fnts;
    };
  };
}
