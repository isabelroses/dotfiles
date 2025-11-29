{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
lib.extendMkDerivation {
  constructDrv = buildNpmPackage;

  extendDrvArgs =
    finalAttrs:
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
            rev = "ec7334e9bb636f4771580238bd3569b58dbce879";
            hash = "sha256-C2b6upygLE6xUP/cTSKZfVjMXOXOOqpP5Xmgb9r2dhA=";
          }
          + "/extensions/${extName}"
        );

      dontNpmInstall = true;
      buildPhase = ''
        npm run build -- --out=$out
      '';
    };
}
