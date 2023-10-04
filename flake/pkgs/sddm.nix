{
  pkgs,
  lib,
}: let
  commit = "7fc67d1027cdb7f4d833c5d23a8c34a0029b0661";
in
  pkgs.stdenv.mkDerivation {
    pname = "sddm-catppucin";
    version = builtins.substring 0 7 commit;

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = commit;
      sha256 = "sha256-SjYwyUvvx/ageqVH5MmYmHNRKNvvnF3DYMJ/f2/L+Go=";
    };

    dontBuild = true;
    installPhase = ''
      mkdir -p $out/
      cp -R $src/src/catppuccin-mocha/* $out/
    '';

    meta = with lib; {
      description = "Catppucin for SDDM";
      homepage = "https://github.com/catppuccin/sddm";
      license = licenses.mit;
      maintainers = with maintainers; [isabelroses];
      platforms = platforms.linux;
    };
  }
