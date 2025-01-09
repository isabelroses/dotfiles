{ inputs, prev, ... }:
{
  # https://github.com/NixOS/nixpkgs/pull/371815
  inherit (inputs.nixpkgs-regression.legacyPackages.${prev.stdenv.hostPlatform.system})
    matrix-synapse-unwrapped
    ;
}
