{ lib, buildGoModule }:
let
  version = "0.0.1";
in
buildGoModule {
  pname = "example-go";
  inherit version;

  src = ./.;

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "A example go project using nix";
    homepage = "https://github.com/isabelroses/example-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainPackage = "example";
  };
}
