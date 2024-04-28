{
  lib,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "jumpies";
  version = "0.1.0";

  src = ./jumpies.zip;

  nativeBuildInputs = [unzip];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp *.png $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Jumpies emojis repacked as APNG";
    license = licenses.unfree;
    maintainers = with maintainers; [isabelroses];
  };
}
