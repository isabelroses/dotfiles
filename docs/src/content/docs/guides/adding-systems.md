---
title: Adding systems
description: How to declare a new system configuration in this flake.
---

The per-system configuration lives in `/systems/<hostname>/`. To wire a host
into the flake it must be declared in `nixosConfigurations` (or
`darwinConfigurations`) inside
[`modules/flake/default.nix`](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/default.nix).

Each entry is passed through the `mkHost` helper at
[`modules/flake/lib/mkhost.nix`](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/lib/mkhost.nix).
It accepts the following options:

- **arch**
  - default: `"x86_64"`
  - options: `"x86_64"`, `"aarch64"`
- **class**
  - default: `"nixos"`
  - options: `"nixos"`, `"darwin"`, `"iso"`
- **modules**
  - default: `[ ]`
  - extra NixOS / nix-darwin modules to import on top of the host's `systems/<hostname>/default.nix`
- **specialArgs**
  - default: `{ }`
  - merged on top of the default `specialArgs` (which already includes `inputs` and `self`)

For example, an aarch64 NixOS server:

```nix
nixosConfigurations = mkHosts {
  skadi = {
    arch = "aarch64";
  };
};
```

A macOS host:

```nix
darwinConfigurations = mkHosts {
  tatsumaki = {
    arch = "aarch64";
    class = "darwin";
  };
};
```

The system tuple (e.g. `aarch64-linux`, `x86_64-linux`, `aarch64-darwin`) is derived from `arch` and `class`, so you don't need to set it yourself.
