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
                rev = "7b5905d08a2c9fda456b2e66894ba3e17997a6cb";
                hash = "sha256-u2VtHkzueezRNZIfn0HVA2WCZtSt3VKusAjhaPWvDl4=";
              }
            else
              fetchFromGitHub {
                owner = "raycast";
                repo = "extensions";
                rev = "3b0c72bb82ddef684eeeb9a5d69cb278eecf3efe";
                hash = "sha256-iqITYshrGABjaOWl6AKXuOznvPlfjQkZ3cvFFzthl9M=";

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
