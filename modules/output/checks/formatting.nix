{
  runCommandLocal,
  self,
}:
let
  fmt = self.formatter;
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
