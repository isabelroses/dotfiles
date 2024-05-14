{ lib, buildNpmPackage }:
buildNpmPackage {
  pname = "foo-bar";
  version = "0.1.0";

  src = ./.;

  npmDepsHash = lib.fakeSha256;
}
