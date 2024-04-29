{
  lib,
  unzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "zerotwo";
  version = "0.1.0";

  src = ./emojis;

  nativeBuildInputs = [unzip];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    unzip $src/emojis.zip
    cp * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "emojis repacked as APNG";
    license = licenses.unfree;
    maintainers = with maintainers; [isabelroses];
  };
}
