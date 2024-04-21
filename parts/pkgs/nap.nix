{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "nap";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "maaslalani";
    repo = "nap";
    rev = "4f83f8e54dfb32136abc937e2304076c1142d920";
    hash = "sha256-sRMfFBk9fjeYYCH91HlL+5d17E7KctSwxZyYYk5hDRo=";
  };

  vendorHash = "sha256-bUBHB8mMa3DM9eycqN8EriFZPEjQgeXJemzlPkAd9wY=";

  excludedPackages = ".nap";

  meta = {
    description = "Code snippets in your terminal 🛌";
    mainProgram = "nap";
    homepage = "https://github.com/maaslalani/nap";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [isabelroses];
  };
}
