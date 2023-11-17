{
  fetchFromGitHub,
  lib,
  rustPlatform,
}: let
  commit = "76b728a876741ac724cfb8eaaac1fd467c2d5d0e";
in
  rustPlatform.buildRustPackage rec {
    pname = "lutgen-rs";
    version = builtins.substring 0 7 commit;

    src = fetchFromGitHub {
      owner = "ozwaldorf";
      repo = pname;
      rev = commit;
      sha256 = "ntKNWvVP9m+GQPct9grY/1AfXGdHpLuYzTwiV1FY6vY=";
    };

    cargoSha256 = "sha256-StVgZBZ36fTneTtZAg5rlpqG0JVFlEDYFeBpk+8Hg+o=";

    meta = {
      description = "A blazingly fast interpolated LUT generator and applicator for arbitrary and popular color palettes. Theme any image to your dekstop colorscheme!";
      homepage = "https://github.com/ozwaldorf/lutgen-rs";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [isabelroses];
      platforms = lib.platforms.linux;
    };
  }
