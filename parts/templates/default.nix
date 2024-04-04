{lib, ...}: {
  flake.templates = lib.pipe ./. [
    builtins.readDir
    (builtins.filter (n: n != "default.nix"))
    (builtins.mapAttrs (name: _: {
      description = name;
      path = ./${name};
    }))
  ];
}
