{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib.trivial) pipe;
  inherit (lib.attrsets) filterAttrs mapAttrs';
in
{
  environment = {
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

    systemPackages = with pkgs; [
      git # git is required for flakes
      cachix # cachix for binary substituters
    ];
  };
}
