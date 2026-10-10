{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
lib.customisation.extendMkDerivation {
  constructDrv = buildNpmPackage;

  extendDrvArgs =
    finalAttrs:
    {
      extName,
      version ? "0",
      type ? "vicinae",
      ...
    }@args:
    lib.trivial.checkListOfEnum "${finalAttrs.pname}: type must be one of vicinae or raycast"
      [ "vicinae" "raycast" ]
      [ type ]
      {
        pname = args.pname or "${type}-extension-${extName}";
        inherit version;

        src =
          args.src or (
            if type == "vicinae" then
              fetchFromGitHub {
                owner = "vicinaehq";
                repo = "extensions";
                rev = "56b0e02307f7dea3ca013e8a5c96128c700eec75";
                hash = "sha256-x500JT5z1ef6AHgjU4IMS8AFVWW+UVn925mYkYGWZVc=";
              }
            else
              fetchFromGitHub {
                owner = "raycast";
                repo = "extensions";
                rev = "b8d63f2c8578215e2d7d5c25784245bca8c3bf4a";
                hash = "sha256-0b50Pc/V8EVlHspsZ3V5Wk/qCcGmjWAtfRVmIjJaCWg=";

                # littrally grind to a halt if we don't add this
                sparseCheckout = [ "/extensions/${extName}" ];
              }
          )
          + "/extensions/${extName}";

        dontNpmInstall = true;
        buildPhase = ''
          runHook preBuild

          npm run build -- -o "$out"

          runHook postBuild
        '';
      };
}
