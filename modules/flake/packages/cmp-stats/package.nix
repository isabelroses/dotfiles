{
  lib,
  python3,
  stdenvNoCC,
  makeWrapper,
}:
let
  python = python3.withPackages (ps: [
    ps.numpy
    ps.pandas
    ps.scipy
    ps.tabulate
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "cmp-stats";
  version = "0";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/cmp-stats

    cp ${./cmp-stats.py} "$out/share/cmp-stats/cmp-stats.py"

    makeWrapper ${python.interpreter} "$out/bin/cmp-stats" \
        --add-flags "$out/share/cmp-stats/cmp-stats.py"

    runHook postInstall
  '';

  meta = {
    description = "Performance comparison of Nix evaluation statistics";
    license = lib.licenses.mit;
    mainProgram = "cmp-stats";
    maintainers = with lib.maintainers; [ isabelroses ];
  };
}
