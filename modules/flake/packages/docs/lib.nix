{
  stdenvNoCC,
  lib,
  nixdoc,
  self,

  libset ? [
    {
      name = "hardware";
      description = "deterministic hardware";
    }
    {
      name = "helpers";
      description = "helpers";
    }
    {
      name = "secrets";
      description = "secrets";
    }
    {
      name = "services";
      description = "services";
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
      description=$3
      nixdoc -c "$name" -d "lib.$name: $description" -f "$name.nix" > "$out/$name.md"
      echo "- [$name](lib/$name.md)" >> "$out/index.md"
    }

    ${lib.concatMapStrings (
      {
        name,
        description,
      }:
      ''
        docgen ${name} ${lib.escapeShellArg description}
      ''
    ) libset}

    runHook postInstall
  '';
}
