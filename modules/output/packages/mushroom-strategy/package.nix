{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mushroom-strategy";
  version = "3.2.0";

  # upstream commits the built bundle to dist/ instead of attaching it to releases
  src = fetchurl {
    url = "https://raw.githubusercontent.com/DigiLive/mushroom-strategy/v${finalAttrs.version}/dist/mushroom-strategy.js";
    hash = "sha256-XADFnvIsOp+28k87aCLWquXop3+HCEWbQ5mJ5tTgtfU=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/mushroom-strategy.js
    runHook postInstall
  '';

  passthru.entrypoint = "mushroom-strategy.js";

  meta = {
    description = "Automatically generated Home Assistant dashboard using Mushroom cards";
    homepage = "https://github.com/DigiLive/mushroom-strategy";
    license = lib.licenses.mit;
  };
})
