---
title: Adding packages
description: How to add packages to your user or system profile in this flake.
---

Adding packages to your user or system profile is different than most other flakes. In this flake we use the `garden.packages` attribute to add our packages, which takes an attrset. This prevents us from having duplicate listings of packages, and lets us think a little less when writing home-manager or nixos/darwin module code.

An example of this might look like the following:

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
