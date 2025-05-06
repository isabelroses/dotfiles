{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    elem
    pipe
    optionals
    filterAttrs
    mapAttrs'
    mkForce
    ;

  commonPaths =
    [
      "nixpkgs"
      "tgirlpkgs"
    ]
    ++ optionals pkgs.stdenv.hostPlatform.isDarwin [
      "nix-darwin"
    ];
in
{
  environment = {
    # https://github.com/NixOS/nixpkgs/blob/eca4605163a534aed1981de0f5f1d7d7639d1640/nixos/modules/programs/environment.nix#L18
    variables.NIXPKGS_CONFIG = mkForce "";

    # something something backwards compatibility something something nix channels
    etc = pipe config.nix.registry [
      (filterAttrs (name: _: elem name commonPaths))
      (mapAttrs' (
        name: value: {
          name = "nix/path/${name}";
          value.source = value.flake;
        }
      ))
    ];
  };
}
