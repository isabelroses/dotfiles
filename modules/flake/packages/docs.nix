{
  stdenvNoCC,
  mdbook,
  mdbook-alerts,
  fetchurl,
  simple-http-server,
  writeShellApplication,
  self,
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
      url = "https://github.com/catppuccin/mdBook/releases/download/v3.1.0/catppuccin.css";
      hash = "sha256-J9eEwC1tTA9RFyivVfF1fqoXgpz1l3gikDpgQF2h3hE=";
    };

    catppuccin-alerts = fetchurl {
      url = "https://github.com/catppuccin/mdBook/releases/download/v3.1.0/catppuccin-alerts.css";
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
