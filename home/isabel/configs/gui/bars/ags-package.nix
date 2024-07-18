{
  lib,
  gtk3,
  esbuild,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "ags-config";
  version = "0.1.0";

  src = ./ags;

  nativeBuildInputs = [ gtk3 ];

  buildPhase = ''
    ${lib.meta.getExe esbuild} \
      --bundle ./main.ts \
      --outfile=main.js \
      --format=esm \
      --external:resource://\* \
      --external:gi://\* \
  '';

  installPhase = ''
    mkdir -p $out
    cp -r assets $out
    cp -r style $out
    cp -f main.js $out/config.js
  '';
}
