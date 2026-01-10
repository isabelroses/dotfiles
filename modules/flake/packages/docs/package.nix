{
  stdenvNoCC,
  mdbook,
  mdbook-alerts,
  fetchurl,
  simple-http-server,
  writeShellApplication,

  libdoc,

  inputs,
  self ? inputs.self,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "docs";

  src = self + /docs;

  nativeBuildInputs = [ mdbook ];

  buildPhase = ''
    runHook preBuild

    mkdir -p theme
    cp ${finalAttrs.passthru.catppuccin-mdbook} theme/catppuccin.css

    cp -r ${libdoc} src/lib

    substituteInPlace src/SUMMARY.md \
      --replace-fail "libdoc" "$(cat src/lib/index.md)"

    mdbook build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r ./dist $out
    runHook postInstall
  '';

  passthru = {
    # TODO: update me when a new version is released
    catppuccin-mdbook = fetchurl {
      url = "https://github.com/catppuccin/mdBook/releases/download/v3.1.1/catppuccin.css";
      hash = "sha256-WSl6UaRfx2jwcDg/ZlDlRbB5zwBD7YIuHHPwFj5ldKM=";
    };

    serve = writeShellApplication {
      name = "serve";

      runtimeInputs = [ simple-http-server ];

      text = ''
        simple-http-server -i -- ${finalAttrs.finalPackage}
      '';
    };
  };
})
