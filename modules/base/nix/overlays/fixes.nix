_: prev:
let
  version = "0.24.6";

  vikunja-frontend = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "vikunja-frontend";

    src = prev.fetchFromGitHub {
      owner = "go-vikunja";
      repo = "vikunja";
      tag = "v${version}";
      hash = "sha256-yUUZ6gPI2Bte36HzfUE6z8B/I1NlwWDSJA2pwkuzd34=";
    };

    patches = [
      ./vikunja-tailwind.patch
    ];

    sourceRoot = "${finalAttrs.src.name}/frontend";

    pnpmDeps = prev.pnpm.fetchDeps {
      inherit (finalAttrs)
        pname
        version
        patches
        src
        sourceRoot
        ;
      hash = "sha256-94ZlywOZYmW/NsvE0dtEA81MeBWGUrJsBXTUauuOmZM=";
    };

    nativeBuildInputs = [
      prev.nodejs
      prev.pnpm.configHook
    ];

    doCheck = true;

    postBuild = ''
      pnpm run build
    '';

    checkPhase = ''
      pnpm run test:unit --run
    '';

    installPhase = ''
      cp -r dist/ $out
    '';
  });
in
{
  # https://github.com/NixOS/nixpkgs/pull/375667
  vikunja = prev.vikunja.overrideAttrs (_: {
    frontend = vikunja-frontend;

    prePatch = ''
      cp -r ${vikunja-frontend} frontend/dist
    '';
  });
}
