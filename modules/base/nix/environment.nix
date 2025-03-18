{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib.trivial) pipe;
  inherit (lib.lists) optionals;
  inherit (lib.attrsets) filterAttrs mapAttrs';
  inherit (lib.modules) mkForce;
in
{
  environment = {
    # git is required for flakes
    systemPackages = [ pkgs.gitMinimal ];

    # https://github.com/NixOS/nixpkgs/blob/eca4605163a534aed1981de0f5f1d7d7639d1640/nixos/modules/programs/environment.nix#L18
    variables.NIXPKGS_CONFIG = mkForce "";

    # something something backwards compatibility something something nix channels
    etc =
      let
        inherit (config.nix) registry;
        commonPaths =
          [
            "nixpkgs"
            "tgirlpkgs"
            "home-manager"
          ]
          ++ optionals pkgs.stdenv.hostPlatform.isDarwin [
            "nix-darwin"
          ];
      in
      pipe registry [
        (filterAttrs (name: _: (elem name commonPaths)))
        (mapAttrs' (
          name: value: {
            name = "nix/path/${name}";
            value.source = value.flake;
          }
        ))
      ];
  };
}
