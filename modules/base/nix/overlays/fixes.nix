{
  nixpkgs.overlays = [
    # TODO: remove when https://github.com/NixOS/nixpkgs/pull/335559 reaches nixpkgs-unstable
    (final: prev: {
      vscode-langservers-extracted = prev.vscode-langservers-extracted.overrideAttrs (_: {
        buildPhase =
          let
            extensions =
              if final.stdenv.isDarwin then
                "../VSCodium.app/Contents/Resources/app/extensions"
              else
                "../resources/app/extensions";
          in
          ''
            npx babel ${extensions}/css-language-features/server/dist/node \
              --out-dir lib/css-language-server/node/
            npx babel ${extensions}/html-language-features/server/dist/node \
              --out-dir lib/html-language-server/node/
            npx babel ${extensions}/json-language-features/server/dist/node \
              --out-dir lib/json-language-server/node/
            cp -r ${final.vscode-extensions.dbaeumer.vscode-eslint}/share/vscode/extensions/dbaeumer.vscode-eslint/server/out \
              lib/eslint-language-server
          '';
      });
    })
  ];
}
