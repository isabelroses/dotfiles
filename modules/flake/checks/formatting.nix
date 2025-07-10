{ self, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      checks.formatting =
        pkgs.runCommandNoCCLocal "formatting-checks" { nativeBuildInputs = [ config.formatter ]; }
          ''
            cd ${self}
            treefmt --no-cache --fail-on-change
            touch $out
          '';
    };
}
