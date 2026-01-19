{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
lib.extendMkDerivation {
  constructDrv = buildNpmPackage;

  extendDrvArgs =
    _:
    {
      extName,
      version ? "0",
      ...
    }@args:
    {
      pname = args.pname or "vicinae-extension-${extName}";
      inherit version;

      src =
        args.src or (
          fetchFromGitHub {
            owner = "vicinaehq";
            repo = "extensions";
            rev = "cc3326e7e07b4d2d0aa9ebc1a54ee3b0fb1db469";
            hash = "sha256-bDC2q3GlDjEE5J2SPHpIdbYKcuLDw3fsxSh3emMOEXU=";
          }
          + "/extensions/${extName}"
        );

      dontNpmInstall = true;
      buildPhase = ''
        npm run build -- --out=$out
      '';
    };
}
