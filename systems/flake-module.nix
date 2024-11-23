{
  lib,
  inputs,
  config,
  withSystem,
  ...
}:
let
  inherit (builtins) mapAttrs attrValues;
  inherit (lib.options) mkOption;
  inherit (lib) types;
  inherit (lib.attrsets) foldAttrs;

  # we import weirdly like this otherwise we get infinite recursion
  inherit (builders) mkSystem;
  builders = import ../parts/lib/builders.nix {
    inherit inputs withSystem;
    inherit (inputs.self) lib;
  };

  constructSystem =
    target: arch:
    if (target == "iso" || target == "nixos") then "${arch}-linux" else "${arch}-${target}";
in
{
  options.hosts = mkOption {
    default = { };
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            arch = mkOption {
              type = types.str;
              default = "x86_64";
            };

            target = mkOption {
              type = types.str;
              default = "nixos";
            };

            system = mkOption {
              type = types.str;
              internal = true;
              default = constructSystem config.hosts.${name}.target config.hosts.${name}.arch;
            };

            deployable = mkOption {
              type = types.bool;
              default = false;
            };

            modules = mkOption {
              type =
                let
                  typ = types.listOf (types.either types.path types.pathInStore);
                in
                types.either (types.listOf typ) typ;
              default = [ ];
            };

            specialArgs = mkOption {
              type = types.attrs;
              default = { };
            };
          };
        }
      )
    );
  };

  config.flake = foldAttrs (host: acc: host // acc) { } (
    attrValues (
      mapAttrs (
        name: cfg:
        mkSystem {
          inherit name;
          inherit (cfg)
            target
            system
            modules
            specialArgs
            ;
        }
      ) config.hosts
    )
  );
}
