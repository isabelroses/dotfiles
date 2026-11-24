{
  buildNpmPackage,
  importNpmLock,
  nodejs,
  simple-http-server,
  writeShellApplication,

  libdoc,
  optiondoc,
  topology,

  inputs,
  self ? inputs.self,
}:
buildNpmPackage (finalAttrs: {
  pname = "docs";
  version = "0.0.1";

  src = self + /docs;

  npmDeps = importNpmLock { npmRoot = self + /docs; };
  inherit (importNpmLock) npmConfigHook;

  nativeBuildInputs = [ nodejs ];

  preBuild = ''
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

    cp -r ${optiondoc} src/content/docs/options

    # the public copy gives the readme a stable url
    cp ${topology}/topology.webp src/assets/topology.webp
    mkdir -p public
    cp ${topology}/topology.webp public/topology.webp
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
