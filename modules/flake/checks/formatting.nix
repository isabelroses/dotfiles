{
  stdenvNoCC,
  runCommandLocal,
  self,
}:
let
  fmt = self.formatter.${stdenvNoCC.hostPlatform.system};
in
runCommandLocal "formatting-checks" { nativeBuildInputs = [ fmt ]; } ''
  cd ${self}
  treefmt --no-cache --fail-on-change
  touch $out
''
