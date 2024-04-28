{
  lib,
  unzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "jumpies";
  version = "0.1.0";

  src = ./emojis;

  nativeBuildInputs = [unzip];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    unzip $src/jumpies.zip
    cp * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Jumpies emojis repacked";
    license = licenses.unfree;
    maintainers = with maintainers; [isabelroses];
  };
}
