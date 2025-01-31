Adding packages to your user or system profile is different then most other
flakes. In this flake we use the `garden.packages` attribute to add our
packages, which take a attrset. This prevents us from having duplicate listsings
of packages, and also lets us think a little less when writing home-manger or
nixos/darwin module code.

An example of this may look like the following:

```nix
{ pkgs, ... }:
{
  garden.packages = {
    inherit (pkgs) git;

    wrapped-nvim = pkgs.symlinkJoin {
      name = "wrapped-nvim";
      paths = [ pkgs.nvim pkgs.astro-language-server ];
    };
  };
}
```
