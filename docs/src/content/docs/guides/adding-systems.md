---
title: Adding systems
description: How to declare a new system configuration in this repo.
---

The per-system configuration lives in `/systems/<hostname>/`. To wire a host
into the config it must be declared in `hosts` at the top of
[`default.nix`](https://github.com/isabelroses/dotfiles/blob/main/default.nix).

Each entry is passed through the `mkHost` helper at
[`modules/output/lib/mkhost.nix`](https://github.com/isabelroses/dotfiles/blob/main/modules/output/lib/mkhost.nix).
It accepts the following options:

- **arch**
  - default: `"x86_64"`
  - options: `"x86_64"`, `"aarch64"`
- **class**
  - default: `"nixos"`
  - options: `"nixos"`, `"darwin"`, `"iso"`

Every host's modules receive `inputs` (what we take from each pin, each with the
`outPath` of its source), `self` (this repo's outputs) and `root` (the repo as a path) as
arguments.

For example, an aarch64 NixOS server:

```nix
hosts = {
  skadi = {
    arch = "aarch64";
  };
};
```

A macOS host:

```nix
hosts = {
  tatsumaki = {
    arch = "aarch64";
    class = "darwin";
  };
};
```

The system tuple (e.g. `aarch64-linux`, `x86_64-linux`, `aarch64-darwin`) is derived from `arch` and `class`, so you don't need to set it yourself.
