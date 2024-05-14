{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "d45b1e7de8cbcb692def0e94111262cdeff2835d";
in
buildGoModule {
  pname = "gh-eco";
  inherit version;

  src = fetchFromGitHub {
    owner = "isabelroses";
    repo = "gh-eco";
    rev = "${version}";
    sha256 = "sha256-zIA7zwzl+Kge9szGkR93QR+Z2V7BQRZq/ShEytNp7Bg=";
  };

  vendorHash = "sha256-O3FQ+Z3KVYgTafwVXUhrGRuOAWlWlOhtVegKVoZBnDE=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = {
    description = "a working fork of gh-eco";
    homepage = "https://github.com/isabelroses/gh-eco";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ isabelroses ];
    platforms = lib.platforms.all;
  };
}
