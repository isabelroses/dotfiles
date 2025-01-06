{ lib, stdenv }:
stdenv.mkDerivation {
  pname = "example-nix";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.intersection (lib.fileset.fromSource (lib.sources.cleanSource ./.)) (
      lib.fileset.unions [
        # files
      ]
    );
  };

  meta = {
    homepage = "https://github.com/isabelroses/example-nix";
    description = "An example Nix project";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainPackage = "example";
  };
}
