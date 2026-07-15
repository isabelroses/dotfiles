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
                rev = "afb84fe4b5253777ff82db8e19e6cc0c9b7f811f";
                hash = "sha256-Non+frT3WG0TN60zCq63m8+d7yNmCCMaI363kZaDmPM=";
              }
            else
              fetchFromGitHub {
                owner = "raycast";
                repo = "extensions";
                rev = "6b00026a230c116ca890b6e8c0b0a343cd6cbae7";
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
