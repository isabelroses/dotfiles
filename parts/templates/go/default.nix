{ lib, buildGoModule }:
buildGoModule {
  pname = "example-go";
  version = "0.0.1";

  src = ./.;

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A example go project using nix";
    homepage = "https://github.com/isabelroses/example-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainPackage = "example";
  };
}
