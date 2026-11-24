{
  stdenvNoCC,
  lib,
  nixdoc,

  inputs,
  self ? inputs.self,

  libset ? [
    {
      name = "helpers";
      description = "helpers";
    }
    {
      name = "mkhost";
      description = "turns a host from fleet.toml into a nixos or darwin system";
    }
    {
      name = "modules";
      description = "what service modules use";
    }
    {
      name = "palette";
      description = "oledpuccin, the colours everything the fleet serves uses";
    }
    {
      name = "validators";
      description = "validators";
    }
  ],
}:
stdenvNoCC.mkDerivation {
  name = "lib-docs";

  src = self + /modules/flake/lib;

  nativeBuildInputs = [
    nixdoc
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"

    function docgen {
      name=$1
      description=$2
      nixdoc -c "$name" -d "lib.$name: $description" -f "$name.nix" > "$out/$name.md"
    }

    ${lib.strings.concatMapStrings (
      {
        name,
        description,
      }:
      ''
        docgen ${name} ${lib.strings.escapeShellArg description}
      ''
    ) libset}

    runHook postInstall
  '';
}
