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
                rev = "ffbb04567d5108a0fb197aedb7642a0aa6ae7aad";
                hash = "sha256-1Q/vrarA1M5rIIOZeSmqpC2e33ncpI7dL8AkNIHgtVo=";
              }
            else
              fetchFromGitHub {
                owner = "raycast";
                repo = "extensions";
                rev = "9b5cbcb7204b895e478f58db1485559b7f7d28d8";
                hash = "sha256-ARrEyBSqw0RSSoRZBCLoiN3Bg1OSKC+uPkwfO29KkfA=";

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
