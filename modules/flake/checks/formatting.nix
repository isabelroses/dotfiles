{
  stdenvNoCC,
  runCommandLocal,
  self,
}:
let
  fmt = self.formatter.${stdenvNoCC.hostPlatform.system};
in
runCommandLocal "formatting-checks"
  {
    nativeBuildInputs = [ fmt ];
    __structuredAttrs = true;
    strictDeps = true;
  }
  ''
    cd ${self}
    treefmt --ci
    touch $out
  ''
