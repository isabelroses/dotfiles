{inputs, ...}: let
  schemas = import ./schemas.nix;
in {
  flake = {
    # extensible flake schemas
    # https://github.com/DeterminateSystems/flake-schemas
    schemas = inputs.flake-schemas.schemas // schemas;
  };
}
