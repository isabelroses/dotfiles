{
  stdenvNoCC,
  mdbook,
  mdbook-alerts,
  fetchurl,
  simple-http-server,
  writeShellApplication,

  libdoc,
  optionsdoc,

  inputs,
  self ? inputs.self,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "docs";

  src = self + /docs;

  nativeBuildInputs = [
    mdbook
    mdbook-alerts
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p theme
    cp ${finalAttrs.passthru.catppuccin-mdbook} theme/catppuccin.css
    cp ${finalAttrs.passthru.catppuccin-alerts} theme/catppuccin-alerts.css

    cp -r ${libdoc} src/lib
    cp -r ${optionsdoc} src/options

    substituteInPlace src/SUMMARY.md \
      --replace-fail "libdoc" "$(cat src/lib/index.md)" \
      --replace-fail "optionsdoc" "$(cat src/options/index.md)"

    mdbook build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r ./dist $out

    runHook postInstall
  '';

  passthru = {
    catppuccin-mdbook = fetchurl {
      url = "https://github.com/catppuccin/mdBook/releases/download/v3.1.1/catppuccin.css";
      hash = "sha256-WSl6UaRfx2jwcDg/ZlDlRbB5zwBD7YIuHHPwFj5ldKM=";
    };

    catppuccin-alerts = fetchurl {
      url = "https://github.com/catppuccin/mdBook/releases/download/v3.1.1/catppuccin-alerts.css";
      hash = "sha256-TnOuFi/0LeIj9pwg9dgfyDpd1oZVCN18dvjp8uB+K78=";
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
