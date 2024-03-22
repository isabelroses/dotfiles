{
  lib,
  pkgs,
}: let
  commit = "a487ae20737d5014ed986cb0e207cc011726a485";
in
  pkgs.stdenv.mkDerivation {
    pname = "sddm-catppucin";
    version = builtins.substring 0 7 commit;

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = commit;
      sha256 = "sha256-SdpkuonPLgCgajW99AzJaR8uvdCPi4MdIxS5eB+Q9WQ=";
    };

    buildInputs = with pkgs; [just];

    buildPhase = ''
      just build
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
