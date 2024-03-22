{
  lib,
  pkgs,
}: let
  commit = "fe7aacfe16bc31f442a27a0b46330872a479bcad";
in
  pkgs.stdenv.mkDerivation {
    pname = "sddm-catppucin";
    version = builtins.substring 0 7 commit;

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = commit;
      sha256 = "sha256-h/sffVhClkm9uIRU3LYaAuEUJHPGkYF+C/NN9rCyZ/c=";
    };

    buildPhase = ''
      ./build.sh nozip
    '';

    installPhase = ''
      mkdir -p $out/
      cp -R dist/* $out/
    '';

    meta = {
      description = "Catppucin for SDDM";
      homepage = "https://github.com/catppuccin/sddm";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [isabelroses];
      platforms = lib.platforms.linux;
    };
  }
