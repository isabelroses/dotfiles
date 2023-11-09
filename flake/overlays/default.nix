{
  flake.overlays.defaults = final: prev:
    prev.lib.composeManyExtensions
    (
      prev.lib.pipe ./. [
        builtins.readDir
        builtins.attrNames

        (builtins.filter (n: n != "default.nix"))
        (map (f: import ./${f}))
      ]
    )
    final
    prev;
}
