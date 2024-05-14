{
  stdenv,
  fetchurl,
  unzip,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "headscale-ui";
  version = "2023.01.30-beta-1";

  src = fetchurl {
    url = "https://github.com/gurucomputing/${pname}/releases/download/${version}/headscale-ui.zip";
    sha256 = "sha256-6SUgtSTFvJWNdsWz6AiOfUM9p33+8EhDwyqHX7O2+NQ=";
  };

  buildInputs = [ unzip ];

  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    mkdir -p $out/share/
    cp -r web/ $out/share/
  '';

  meta = {
    description = "A web frontend for the headscale Tailscale-compatible coordination server";
    homepage = "https://github.com/gurucomputing/headscale-ui";
    license = [ lib.licenses.bsd3 ];
  };
}
