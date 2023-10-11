{inputs, ...}: let
  schemas = import ./schemas.nix;
in {
  flake = {
    # extensible flake schemas
    schemas = inputs.flake-schemas.schemas // schemas;
  };
}
