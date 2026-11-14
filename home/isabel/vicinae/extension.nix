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
                rev = "181904331f5289b53ee3443f98cfa5441d399f35";
                hash = "sha256-UR269g8GwB5jywGcxqViVscjl8gtvRO9XjtCoGnUbSs=";
              }
            else
              fetchFromGitHub {
                owner = "raycast";
                repo = "extensions";
                rev = "87abd696c19759d2e56553940235d7a653d0b8a6";
                hash = "sha256-y6wFE5XUmSG2NMDKIW+GVcgXnVor4K10vCSjMH+WCZE=";

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
