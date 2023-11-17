{
  pkgs ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  lib ? pkgs.lib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "cyberchef";
  version = "10.4.0";

  src = pkgs.fetchzip {
    url = "https://github.com/gchq/CyberChef/releases/download/v${version}/CyberChef_v${version}.zip";
    sha256 = "sha256-BjdeOTVZUMitmInL/kE6a/aw/lH4YwKNWxdi0B51xzc=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    pkgs.unzip
  ];

  phases = ["installPhase"];

  installPhase = ''
    mkdir $out
    cp -r ${src}/* $out
    cp -r $out/CyberChef_v${version}.html $out/index.html
  '';

  meta = {
    description = " The Cyber Swiss Army Knife - a web app for encryption, encoding, compression and data analysis";
    homepage = "https://gchq.github.io/CyberChef";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [isabelroses];
  };
}
