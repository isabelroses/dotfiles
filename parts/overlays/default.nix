{
  flake.overlays.default = final: prev:
    prev.lib.composeManyExtensions
    (
      prev.lib.pipe ./. [
        builtins.readDir
        builtins.attrNames
        (builtins.filter (name: name != "default.nix"))
        (map (file: import ./${file}))
      ]
    )
    final
    prev;
}
