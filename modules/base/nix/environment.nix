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
in
{
  environment = {
    # git is required for flakes
    systemPackages = [ pkgs.git ];

    # something something backwards compatibility something something nix channels
    etc =
      let
        inherit (config.nix) registry;
        commonPaths =
          [
            "nixpkgs"
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
