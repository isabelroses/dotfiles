{ lib, buildNpmPackage }:
buildNpmPackage {
  pname = "example-nodejs";
  version = "0.1.0";

  src = ./.;

  npmDepsHash = lib.fakeSha256;

  meta = {
    description = "A example nodejs project using nix";
    homepage = "https://github.com/isabelroses/example-nodejs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainPackage = "example";
  };
}
