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
      type ? "vicinae",
      ...
    }@args:
    lib.checkListOfEnum "${finalAttrs.pname}: type must be one of vicinae or raycast"
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
                rev = "c7a8d7d2e3fa599922c4964a94315c55c9bfe80b";
                hash = "sha256-M2hmGokQXbvoKUEvkgF2IIxOUGCF5v7bXyjPzpSQIJw=";
              }
            else
              fetchFromGitHub {
                owner = "raycast";
                repo = "extensions";
                rev = "b51d43359d1b3bde44046956bb53aecb7549c0da";
                hash = "sha256-pSUiNWo8D/ZMEcivMR/uSUGHBpVTW3ITdKBlWf/GmtU=";

                # littrally grind to a halt if we don't add this
                sparseCheckout = [ "/extensions/${extName}" ];
              }
          )
          + "/extensions/${extName}";

        dontNpmInstall = true;
        buildPhase = ''
          npm run build -- -o=$out
        '';
      };
}
