{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  python3,
  simple-http-server,
  writeShellApplication,
  writeText,

  fraunces,
  inter,

  fleetdoc,
  libdoc,
  optiondoc,
  topology,

  inputs,
  self ? inputs.self,
}:
let
  # latin, plus the punctuation and arrows the pages use
  unicodes = "U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+2000-206F,U+20AC,U+2122,U+2190-21FF,U+2212,U+2215,U+25B8,U+25CF";

  # a dirty tree has no rev, and the footer says so rather than guessing
  rev = self.shortRev or self.dirtyShortRev or "unknown";
  date = self.lastModifiedDate or "";

  # custom.css imports this for its oledpuccin colours
  palette = writeText "palette.css" ''
    :root {
    ${
      lib.strings.concatStrings (
        lib.attrsets.mapAttrsToList (name: hex: "  --palette-${name}: ${hex};\n") self.lib.palette.colors
      )
    }}
  '';
in
buildNpmPackage (finalAttrs: {
  pname = "docs";
  version = "0.0.1";

  src = self + /docs;

  npmDeps = importNpmLock { npmRoot = self + /docs; };
  inherit (importNpmLock) npmConfigHook;

  nativeBuildInputs = [
    nodejs
    (python3.withPackages (ps: [
      ps.fonttools
      ps.brotli
    ]))
  ];

  env = {
    PUBLIC_DOTFILES_REV = rev;
    PUBLIC_DOTFILES_DATE = lib.optionalString (
      date != ""
    ) "${builtins.substring 0 4 date}-${builtins.substring 4 2 date}-${builtins.substring 6 2 date}";
  };

  preBuild = ''
    cp ${palette} src/styles/palette.css

    mkdir -p src/content/docs/lib
    for file in ${libdoc}/*.md; do
      name=$(basename "$file" .md)
      {
        echo "---"
        echo "title: lib.$name"
        echo "---"
        echo
        # strip nixdoc's mdBook-style heading attributes like `{#function-library-lib.foo}`
        sed -E 's/[[:space:]]*\{#[^}]*\}//g' "$file"
      } > "src/content/docs/lib/$name.md"
    done

    cp -rL ${optiondoc} src/content/docs/options

    # host pages and the services index, from fleet.toml and each host's config
    cp -rL ${fleetdoc}/content/. src/content/docs/
    mkdir -p src/generated
    cp ${fleetdoc}/systems.md src/generated/systems.md

    # the public copy gives the readme a stable url
    cp ${topology}/topology.webp src/assets/topology.webp
    mkdir -p public
    cp ${topology}/topology.webp public/topology.webp

    mkdir -p public/fonts
    subset() {
      pyftsubset "$1" --unicodes=${unicodes} --layout-features='*' \
        --flavor=woff2 --output-file="public/fonts/$2.woff2"
    }
    subset '${fraunces}/share/fonts/truetype/Fraunces[SOFT,WONK,opsz,wght].ttf' fraunces
    subset ${inter}/share/fonts/truetype/InterVariable.ttf inter
    subset ${inter}/share/fonts/truetype/InterVariable-Italic.ttf inter-italic
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist $out
    runHook postInstall
  '';

  passthru = {
    serve = writeShellApplication {
      name = "serve";

      runtimeInputs = [ simple-http-server ];

      text = ''
        simple-http-server -i -- ${finalAttrs.finalPackage}
      '';
    };
  };
})
