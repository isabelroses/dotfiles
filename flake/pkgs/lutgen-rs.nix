{
  lib,
  rustPlatform,
  fetchFromGitHub,
}: let
  pname = "lutgen-rs";
  version = "v0.10.0";
in
  rustPlatform.buildRustPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ozwaldorf";
      repo = pname;
      rev = version;
      sha256 = "sha256-O2995+DLiCRDM/+oPTOBiM0L1x0jmbLTlR48+5IfOQw=";
    };

    cargoSha256 = "sha256-8O60p/Bes0clOdBa2Zfp7b7dzgZgtuV55T+odYeIbjI=";

    meta = {
      description = "A blazingly fast interpolated LUT generator and applicator for arbitrary and popular color palettes. Theme any image to your dekstop colorscheme!";
      homepage = "https://github.com/ozwaldorf/lutgen-rs";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [isabelroses];
      platforms = with lib.platforms; [linux darwin];
    };
  }
