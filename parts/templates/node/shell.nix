{
  eslint_d,
  prettierd,
  callPackage,
  writeShellScriptBin,
}:
let
  mainPkg = callPackage ./default.nix { };
  mkNpxAlias = name: writeShellScriptBin name "npx ${name} \"$@\"";
in
mainPkg.overrideAttrs (oa: {
  nativeBuildInputs = [
    eslint_d
    prettierd
    (mkNpxAlias "tsc")
    (mkNpxAlias "tsserver")
  ] ++ (oa.nativeBuildInputs or [ ]);

  shellHook = ''
    eslint_d start # start eslint daemon
    eslint_d status # inform user about eslint daemon status
  '';
})
