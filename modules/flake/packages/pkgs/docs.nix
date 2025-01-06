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
      sha256 = "04fyl5fl0q1sj0i7i5zmkj11gakyfpqmbbr82x8hyk3d5p089mr7";
    };

    catppuccin-alerts = fetchurl {
      url = "https://github.com/catppuccin/mdBook/releases/latest/download/catppuccin-alerts.css";
      sha256 = "1grbgvhg5sgqfryds22mhvb5sfn83zcga84wyqiy4bgl5wbawwsf";
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
