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
            rev = "62f81e63d0420d6a310092746a96d7c105f7a53e";
            hash = "sha256-Tqd5BOxfCtVWY19Gl32Fq5xsV3sTepItub20OQYgPmU=";
          }
          + "/extensions/${extName}"
        );

      dontNpmInstall = true;
      buildPhase = ''
        npm run build -- --out=$out
      '';
    };
}
