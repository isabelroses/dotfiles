{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks = {
        actionlint = pkgs.runCommand "actionlint" { buildInputs = [ pkgs.actionlint ]; } ''
          actionlint ${self}/.github/workflows/**
        '';
      };
    };
}
