{lib, ...}: {
  flake.templates = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (name: _: name != "default.nix"))
    (builtins.mapAttrs (name: _: {
      description = name;
      path = ./${name};
    }))
  ];
}
