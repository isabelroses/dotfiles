{ self, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      checks.formatting =
        pkgs.runCommandNoCCLocal "formatting-checks" { nativeBuildInputs = [ self'.formatter ]; }
          ''
            cd ${self}
            treefmt --no-cache --fail-on-change
            touch $out
          '';
    };
}
