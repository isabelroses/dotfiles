{ lib, ... }:
{
  flake.templates = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (_: type: type == "directory"))
    (builtins.mapAttrs (
      name: _: {
        description = name;
        path = ./${name};
      }
    ))
  ];
}
