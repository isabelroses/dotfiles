{
  lib,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "zerotwo";
  version = "0.1.0";

  src = ./zerotwo.zip;

  nativeBuildInputs = [unzip];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp *.png $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Zero Two emojis repacked as APNG";
    license = licenses.unfree;
    maintainers = with maintainers; [isabelroses];
  };
}
