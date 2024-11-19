{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib.lists) optionals;
  inherit (lib.attrsets) filterAttrs mapAttrs';
  inherit (lib.modules) mkForce;
in
{
  environment = {
    # git is required for flakes
    systemPackages = [ pkgs.git ];

    # https://github.com/NixOS/nixpkgs/blob/eca4605163a534aed1981de0f5f1d7d7639d1640/nixos/modules/programs/environment.nix#L18
    variables.NIXPKGS_CONFIG = mkForce "";

    # something something backwards compatibility something something nix channels
    etc =
      let
        inherit (config.nix) registry;
        commonPaths = [
          "self"
          "nixpkgs"
          "beapkgs"
          "home-manager"
        ];

        flakes =
          [
            "nixpkgs"
            "beapkgs"
            "home-manager"
          ]
          ++ optionals pkgs.stdenv.hostPlatform.isDarwin [
            "nix-darwin"
          ];
      in
      registry
      |> filterAttrs (name: _: elem name flakes)
      |> mapAttrs' (
        name: value: {
          name = "nix/path/${name}";
          value.source = value.flake;
        }
      );
  };
}
